# Stop synching on a podcast
#   - We could make crier stop sending messages
#     - probably change the feed url it requests, or delete the record
#   - When the podcast doesn't have the series id associated with it, no episodes
#     will be created or sync so we can create and modify them in cms w/o messing up feeder
#
# Script will create the podcast, episodes, and audio in cms
#   - get the data from feeder DB to create the podcast and episodes
#   - copy the ad free audio from feeder to uploads so it will auto cleanup, and match
#     - use the original filename from the file in feeder
#   - cms will use this new audio to copy into the correct story audio file location
#     s3://prx-up/prod/<guid>/<original-filename>
#   - copy this cms location back to the feeder original url, so they are in sync
#   - We need to do the same for the podcast and episode images
#
# For the distribution, create this right away in the cms db using the feeder episode data
#
# After all this is setup in cms, we can then update feeder references to cms
#   - add the `prx_uri` and `prx_account_uri` to the podcast attributes
#   - add the `prx_uri` to the episodes
#   - update the episode page urls (not wordpress or libsyn or whatever anymore)

require 'addressable/uri'
require 'prx_access'

# Feeder models start
# some pidgin models for feeder db
class FeederModel < ActiveRecord::Base
  self.abstract_class = true

  def self.status_values
    [ :started, :created, :processing, :complete, :error, :retrying, :cancelled ]
  end

  def self.feeder_db_connection
    {
      adapter: 'postgresql',
      encoding: 'unicode',
      pool: ENV['FEEDER_DB_POOL_SIZE'] || 2,
      user: ENV['FEEDER_DB_USER'] || 'feeder',
      password: ENV['FEEDER_DB_PASSWORD'],
      host: ENV['FEEDER_DB_HOST'],
      port: ENV['FEEDER_DB_PORT'] || 5432,
      database: ENV['FEEDER_DB_DATABASE'] || 'feeder'
    }
  end

  establish_connection(feeder_db_connection)
end

class Podcast < FeederModel
  has_many :episodes, -> { order('published_at desc') }
  has_many :itunes_images, -> { order('created_at DESC') }
  has_many :feed_images, -> { order('created_at DESC') }
end

class PodcastImage < FeederModel
  belongs_to :podcast
  enum status: status_values
end

class ITunesImage < PodcastImage; end
class FeedImage < PodcastImage; end

class Episode < FeederModel
  belongs_to :podcast
  has_many :episode_images, -> { order('created_at DESC').complete }
  has_many :media_resources, -> { order('position ASC, created_at DESC').complete }
  scope :published, -> { where('published_at IS NOT NULL AND published_at <= now()') }

  serialize :categories, JSON
  serialize :keywords, JSON

  def item_guid
    original_guid || "prx_#{podcast_id}_#{guid}"
  end
end

class EpisodeImage < FeederModel
  belongs_to :episode
  enum status: status_values
end

class MediaResource < FeederModel
  belongs_to :episode
  enum status: status_values
end

class Content < MediaResource; end
class Enclosure < MediaResource; end
# Feeder models end

class FeederImporter
  include Announce::Publisher
  include PRXAccess

  attr_accessor :account_id, :user_id, :podcast_id, :set_episode_urls
  attr_accessor :podcast, :series, :template, :distribution, :stories

  def debug
    TRUE
  end

  def initialize(account_id, user_id, podcast_id, set_episode_urls = false)
    self.account_id = account_id
    self.user_id = user_id
    self.podcast_id = podcast_id
    self.stories = []
    self.set_episode_urls = set_episode_urls
  end

  def import
    retrieve_podcast
    create_series
    create_stories
    update_podcast
  end

  def retrieve_podcast
    self.podcast = Podcast.find(podcast_id)
  end

  def create_series
    attrs = {
      app_version: PRX::APP_VERSION,
      account_id: account_id,
      creator_id: user_id,
      title: podcast.title,
      short_description: podcast.subtitle,
      description_html: podcast.description
    }
    self.series = Series.create!(attrs)

    podcast.itunes_images.each { |i| create_series_image(i, Image::PROFILE) }
    podcast.feed_images.each { |i| create_series_image(i, Image::THUMBNAIL) }

    # all the imports we plan to do from feeder -> cms have a single segment
    num_segments = 1

    self.template = series.audio_version_templates.create!(
      label: "Podcast Audio #{num_segments} #{'segment'.pluralize(num_segments)}",
      segment_count: num_segments,
      promos: false,
      length_minimum: 0,
      length_maximum: 0
    )

    episode = podcast.episodes.first
    if episode.media_resources
      num_segments = [episode.media_resources.count, num_segments].max
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
      url: podcast_id,
      distributable: series,
      audio_version_template: template
    )

    series
  end

  def create_series_image(podcast_image, purpose)
    upload_url = copy_image(SecureRandom.uuid, podcast_image)
    image = series.images.create!(upload: upload_url, purpose: purpose)
    announce_image(image)
    podcast_image.update_attribute(:original_url, image.public_url(version: 'original'))
  end

  def create_stories
    podcast.episodes.each do |episode|
      create_story(episode)
    end
  end

  def create_story(episode)
    # puts "episode.categories: #{episode.categories.inspect}"
    attrs = {
      app_version: PRX::APP_VERSION,
      creator_id: user_id,
      account_id: account_id,
      title: episode.title,
      short_description: episode.subtitle,
      description_html: episode.description,
      tags: episode.categories,
      published_at: episode.published_at
    }
    story = series.stories.create!(attrs)

    version = story.audio_versions.create!(
      audio_version_template: template,
      explicit: episode.explicit
    )

    episode.media_resources.each_with_index do |media_resource, i|
      upload_url = copy_media(episode, media_resource)
      audio = version.audio_files.create!(label: "Segment #{i + 1}", upload: upload_url)
      announce_audio(audio)
      media_resource.update_attribute(:original_url, audio_file_original_url(audio))
    end

    episode.episode_images.each do |episode_image|
      upload_url = copy_image(episode.guid, episode_image)
      image = story.images.create!(upload: upload_url)
      announce_image(image)
      episode_image.update_attribute(:original_url, image.public_url(version: 'original'))
    end

    # create the story distribution
    episode_url = "#{feeder_root}/episodes/#{episode.guid}"
    story.distributions << StoryDistributions::EpisodeDistribution.create!(
      distribution: distribution,
      story: story,
      guid: episode.item_guid,
      url: episode_url
    )

    if set_episode_urls
      new_url = default_url(story)
      puts "new_url: #{new_url}"
      episode.update_attribute(:url, new_url)
    end
    episode.update_attribute(:prx_uri, "/api/v1/stories/#{story.id}")
    stories << story

    story
  end

  def default_url(story)
    path = "#{story.class.name.underscore.pluralize}/#{story.id}"
    ENV['PRX_HOST'].nil? ? nil : "https://#{ENV['PRX_HOST']}/#{path}"
  end

  def audio_file_original_url(af)
    "s3://#{Rails.env}.mediajoint.prx.org/public/audio_files/#{af.id}/#{File.basename(af.filename)}"
  end

  def update_podcast
    podcast.update_attributes(
      prx_account_uri: "/api/v1/accounts/#{account_id}",
      prx_uri: "/api/v1/series/#{series.id}",
      source_url: nil
    )
  end

  def copy_image(guid, image)
    from_path = URI.parse(image.url).path[1..-1]
    to_path = "#{short_env}/#{guid}/#{from_path.split('/').last}"
    copy_file(from_path, to_path)
  end

  def copy_media(episode, media)
    from_path = URI.parse(media.url).path[1..-1]
    to_path = "#{short_env}/#{episode.guid}/#{URI.parse(media.original_url).path.split('/').last}"
    copy_file(from_path, to_path)
  end

  def copy_file(from_path, to_path)
    connection = AudioFileUploader.new.send(:storage).connection
    options = {
      'x-amz-metadata-directive' => 'COPY',
      'x-amz-acl' => 'public-read'
    }
    if debug
      # Leaving this - useful for debugging when not wanting to actually update s3
      # puts "copy_object('prx-feed', #{from_path}', 'prx-up', '#{to_path}', '#{options.inspect}')"
    else
      connection.copy_object('prx-feed', from_path, 'prx-up', to_path, options)
    end

    "https://prx-up.s3.amazonaws.com/#{to_path}"
  end

  def announce_image(image)
    announce('image', 'create', Api::Msg::ImageRepresenter.new(image).to_json)
  end

  def announce_audio(audio)
    announce('audio', 'create', Api::Msg::AudioFileRepresenter.new(audio).to_json)
  end

  def short_env
    {
      'production' => 'prod',
      'staging' => 'stag',
      'development' => 'dev',
      'test' => 'test'
    }[Rails.env.to_s]
  end
end
