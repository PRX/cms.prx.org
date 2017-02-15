# import script for a podcast live in feeder & dovetail
require 'prx_access'
require 'addressable/uri'
require 'feedjira'
require 'itunes_category_validator'

class PodcastImporter
  include PRXAccess

  attr_accessor :cms_account_path, :podcast_url
  attr_accessor :series, :template, :stories, :podcast, :distribution

  def initialize(account, podcast_url)
    self.cms_account_path = account
    self.podcast_url = podcast_url
  end

  def import
    # TODO Check to see if the podcast exists, may need a new query for that
    # could get all series for the account, see if title matches?
    # also may need an `import` table to track this

    # Request the RSS feed
    feed = rss_feed

    # Create the series
    self.series, self.template = create_series(feed)

    # Create the podcast distribution
    self.distribution = create_distribution(series, template)

    # Update podcast attributes
    self.podcast = update_podcast(distribution, feed)

    # Create the episodes
    self.stories = create_stories(feed, series)

    # return true, but the importer has attributes set
    true
  end

  def rss_feed
    response = connection.get(uri.path, uri.query_values)
    Feedjira::Feed.parse(response.body)
  end

  def create_series(podcast)
    # make an api client for the account
    client = api(root: cms_root, account: cms_account_path)
    account = client.tap { |c| c.href = cms_account_path }.get

    # create the series
    series = account.series.post(
      title: podcast.title,
      short_description: podcast.itunes_subtitle,
      description: podcast.description
    )

    # Add images to the series
    if !podcast.itunes_image.blank?
      series.images.post(
        upload: podcast.itunes_image,
        purpose: Image::PROFILE
      )
    end

    if podcast.image && podcast.image.url
      series.images.post(
        upload: podcast.image.url,
        purpose: Image::THUMBNAIL
      )
    end

    # Add the template and a single file template
    self.template = series.audio_version_templates.post(
      label: 'Podcast Audio',
      explicit: podcast.itunes_explicit,
      promos: false,
      length_minimum: 0,
      length_maximum: 0
    )

    template.audio_file_templates.post(
      position: 1,
      label: 'Segment A',
      length_minimum: 0,
      length_maximum: 0
    )

    [series, template]
  end

  def create_distribution(series, template)
    template_link = template.links['self'].href
    series.distributions.post(kind: 'podcast', set_audio_version_template_uri: template_link)
  end

  def update_podcast(distribution, feed)
    podcast = api(root: distribution.podcast.href, headers: distribution.headers).get

    %w(copyright language update_frequency update_period).each do |atr|
      podcast.attributes[atr.to_sym] = feed.send(atr)
    end

    podcast.attributes[:link] = feed.url
    podcast.attributes[:explicit] = feed.itunes_explicit
    podcast.attributes[:new_feed_url] = feed.itunes_new_feed_url
    podcast.attributes[:path] ||= feed.feedburner_name

    podcast.attributes[:author] = person(feed.itunes_author)
    podcast.attributes[:managing_editor] = person(feed.managing_editor)
    podcast.attributes[:owners] = Array(feed.itunes_owners).map do |o|
      { name: o.name, email: o.email }
    end

    podcast.attributes[:itunes_categories] = parse_itunes_categories(feed)
    podcast.attributes[:categories] = parse_categories(feed)
    podcast.attributes[:complete] = (feed.itunes_complete == 'yes')
    podcast.attributes[:copyright] ||= feed.media_copyright
    podcast.attributes[:keywords] = parse_keywords(feed)

    podcast.put
    podcast
  end

  def person(arg)
    return nil if arg.blank?

    email = name = nil
    if arg.is_a?(Hash)
      email = arg[:email]
      name = arg[:name]
    else
      s = arg.to_s.try(:strip)
      if match = s.match(/(.+) \((.+)\)/)
        email = match[1]
        name = match[2]
      else
        name = s
      end
    end

    { name: name, email: email }
  end

  def parse_itunes_categories(feed)
    itunes_cats = {}
    Array(feed.itunes_categories).map(&:strip).select { |c| !c.blank? }.each do |cat|
      if ITunesCategoryValidator.category?(cat)
        itunes_cats[cat] ||= []
      elsif parent_cat = ITunesCategoryValidator.subcategory?(cat)
        itunes_cats[parent_cat] ||= []
        itunes_cats[parent_cat] << cat
      end
    end

    itunes_cats.keys.map { |n| { name: n, subcategories: itunes_cats[n] } }
  end

  def parse_categories(feed)
    mcat = Array(feed.media_categories).map(&:strip)
    rcat = Array(feed.categories).map(&:strip)
    (mcat + rcat).compact.uniq
  end

  def parse_keywords(feed)
    ikey = Array(feed.itunes_keywords).map(&:strip)
    mkey = Array(feed.media_keywords).map(&:strip)
    (ikey + mkey).compact.uniq
  end

  def create_stories(feed, series)
    feed.entries.map do |entry|
      story = create_story(entry, series)
      update_entry(story, entry)
      story
    end
  end

  def create_story(entry, series)
    # create the story - distribution should be auto created
    story_attributes = {
      title: entry[:title],
      short_description: entry[:itunes_subtitle],
      description: entry[:description],
      tags: entry[:categories],
      released_at: entry[:published]
    }
    story = series.stories.post(story_attributes)

    # add the audio version
    self_link = template.links['self'].href
    version_attributes = {
      set_audio_version_template: self_link,
      label: 'Podcast Audio',
      explicit: entry[:itunes_explicit]
    }
    version = story.audio_versions.post(version_attributes)

    # add the audio
    enclosure = enclosure_url(entry)
    version.audio.post(label: 'Segment A', upload: enclosure) if enclosure

    # add the image
    story.images.post(upload: entry.itunes_image) if entry.itunes_image

    # publish this so the released_at gets set as the published_at
    story.publish.post

    story
  end

  def enclosure_url(entry)
    entry[:feedburner_orig_enclosure_link] || entry[:enclosure].try(:url)
  end

  def update_entry(story, entry)
    # find the distro from the story
    distributions = story.distributions.get
    distro = distributions.detect { |d| d.attributes['kind'] == 'episode' }

    # set the guid into the distro, so we can look later for it
    distro.attributes[:guid] = entry.entry_id
    distro.put

    # using authorized endpoint, update the episode guid and other attributes
    episode = api(root: feeder_auth_url(distro.attributes['url']), headers: story.headers)
    episode.attributes[:author] = person(entry[:itunes_author] || entry[:author] || entry[:creator])
    episode.attributes[:block] = (entry[:itunes_block] == 'yes')
    episode.attributes[:explicit] = entry[:itunes_explicit]
    episode.attributes[:guid] = entry.entry_id
    episode.attributes[:is_closed_captioned] = (entry[:itunes_is_closed_captioned] == 'yes')
    episode.attributes[:is_perma_link] = entry[:is_perma_link]
    episode.attributes[:keywords] = (entry[:itunes_keywords] || '').split(',').map(&:strip)
    episode.attributes[:position] = entry[:itunes_order]
    episode.attributes[:url] = episode_url(entry)
    episode.put
    episode
  end

  def feeder_auth_url(url)
    result = url
    if url && !url.match(/authorization/)
      result = url.gsub('/episodes/', '/authorization/episodes/')
    end
    result
  end

  def episode_url(entry)
    url = entry[:feedburner_orig_link] || entry[:url] || entry[:link]
    if url =~ /libsyn\.com/
      url = nil
    end
    url
  end

  def uri
    @uri ||= Addressable::URI.parse(podcast_url)
  end

  def connection
    conn_uri = "#{uri.scheme}://#{uri.host}:#{uri.port}"
    Faraday.new(conn_uri) { |stack| stack.adapter :excon }.tap do |c|
      c.headers[:user_agent] = 'PRX CMS FeedValidator'
    end
  end
end
