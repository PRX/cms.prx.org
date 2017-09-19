require 'prx_access'
require 'addressable/uri'

class FeederImporter
  include PRXAccess
  include Announce::Publisher

  attr_accessor :account_id, :user_id, :feeder_podcast_url
  attr_accessor :podcast, :series, :template, :distribution

  def initialize(account_id, user_id, feeder_podcast_url)
    self.account_id = account_id
    self.user_id = user_id
    self.feeder_podcast_url = feeder_podcast_url
  end

  def import
    retrieve_podcast
    create_series
    create_episodes
  end

  def create_stories(pcast = podcast)
    pcast.episodes.each do |episode|
      create_story(pcast, episode)
    end
  end

  def create_story(pcast, episode)
    attrs = {
      title: episode.attributes[:title],
      description_html: episode.attributes[:description],
      short_description: episode.attributes[:subtitle],
      tags: episode.attributes[:categories],
      published_at: episode.attributes[:published_at]
    }
    story = series.stories.create!(attrs)

    story.audio_versions.create!(
      audio_version_template: template,
      explicit: episode.attributes[:explicit]
    )

    story
  end

  def create_series(pcast = podcast)
    attrs = {
      app_version: PRX::APP_VERSION,
      account_id: account_id,
      creator_id: user_id,
      title: pcast.title,
      short_description: pcast.attributes[:subtitle],
      description_html: pcast.attributes[:description]
    }
    self.series = Series.create!(attrs)

    # Add images to the series
    if pcast.attributes['itunes_image'] && pcast.itunes_image['url']
      image = series.images.create!(
        upload: clean_string(pcast.itunes_image['url']),
        purpose: Image::PROFILE
      )
      announce_image(image)
    end

    if pcast.attributes['feed_image'] && pcast.feed_image['url']
      image = series.images.create!(
        upload: clean_string(pcast.feed_image['url']),
        purpose: Image::THUMBNAIL
      )
      announce_image(image)
    end

    # Add the template and a single file template
    self.template = series.audio_version_templates.create!(
      label: 'Podcast Audio',
      promos: false,
      length_minimum: 0,
      length_maximum: 0
    )

    num_segments = 1
    episode = pcast.episodes.first
    if episode.attributes['media']
      num_segments = [episode.media.count, num_segments].max
    end
    num_segments.times do |x|
      num = x + 1
      template.audio_file_templates.create!(
        position: num,
        label: "Segment #{num}",
        length_minimum: 0,
        length_maximum: 0
      )
    end

    self.distribution = Distributions::PodcastDistribution.create!(
      url: feeder_podcast_url,
      distributable: series,
      audio_version_template: template
    )

    series
  end

  def retrieve_podcast(a_id = account_id, p_url = feeder_podcast_url)
    self.podcast = api(root: feeder_root, account: a_id).tap { |a| a.href = p_url }.get
  end

  def announce_image(image)
    announce('image', 'create', Api::Msg::ImageRepresenter.new(image).to_json)
  end

  def clean_string(str)
    return nil if str.blank?
    return str if !str.is_a?(String)
    str.strip
  end
end
