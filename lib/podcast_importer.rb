# import script for a podcast live in feeder & dovetail
require 'prx_access'
require 'addressable/uri'
require 'feedjira'

class PodcastImporter
  include PRXAccess

  attr_accessor :cms_account_path, :podcast_url

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
    series = create_series(feed)

    # Create the podcast distribution
    distribution = create_distribution(feed, series)

    # Update podcast attributes
    podcast = update_podcast(series, distribution)

    # Create the episodes
    create_stories(feed, series)
  end

  def update_podcast(series, distribution)
    podcast = api(root: distribution.podcast.href, headers: distribution.headers).get
    podcast.attributes[:explicit] = true
    podcast.put
    podcast
  end

  def rss_feed
    response = connection.get(uri.path, uri.query_values)
    feed = Feedjira::Feed.parse(response.body)
  end

  def create_series(podcast)
    series_attributes = {
      title: podcast.title,
      short_description: podcast.itunes_subtitle,
      description: podcast.description
    }

    client = api(root: cms_root, account: cms_account_path).get
    series = client.series.first.post(series_attributes)

    # Add images to the series
    if podcast.itunes_image
      series.images.post(upload: podcast.itunes_image, purpose: Image::PROFILE)
    end

    if podcast.image && podcast.image.url
      series.images.post(upload: podcast.image.url, purpose: Image::THUMBNAIL)
    end

    series
  end

  def create_distribution(podcast, series)
    series.distributions.post(kind: 'podcast')
  end

  def create_stories(feed, series)
    feed.entries.each do |entry|
      story = create_story(entry, series)
      update_entry(story, entry)
    end
  end

  def create_story(entry, series)
    # create the story
    #   distribution should be auto created
    series.stories.post(title: 'test title')

    # add the audio

    # add the image
  end

  def update_entry(story, entry)
    # find the distro from the story
    # retrieve the episode from feeder
    # update the episode guid and other attributes
  end

  def uri
    @uri ||= Addressable::URI.parse(podcast_url)
  end

  def connection
    conn_uri = "#{uri.scheme}://#{uri.host}:#{uri.port}"
    client ||= Faraday.new(conn_uri) { |stack| stack.adapter :excon }.tap do |c|
      c.headers[:user_agent] = "PRX CMS FeedValidator"
    end
  end
end
