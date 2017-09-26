# Stop synching on a podcast
#   - blank out the source_url on the podcast, this means any updates that do come in will create/affect a different feed
#   - make crier stop (?) sending messages - probably have to change the url it reads from to a failing url
#   - when the podcast doesn't have the series id associated with it, no episodes will be created or sync so we can create and modify them in cms w/o messing up feeder
#
# Create the podcast, episodes, and audio in cms
#   - get the data from feeder api to create the podcast and episodes
#   - copy the ad free audio from feeder to a new location (to uploads so it will auto cleanup)
#   - use the filename from the updated feeder api
#   - cms will use this new audio to copy into the correct story audio file location
#     s3://prx-up/prod/<guid>/<original-filename>
#
# We need to do the same for the images, keeping the filename.
#
# For the distribution, we can create this right away in the cms db using the feeder episode api link
#
# After all this is setup in cms, we can then update feeder to match
#   - update the original file urls in feeder to use these new cms urls - do not trigger processing on this (db change?)
#   - this will make sure we have the files in synch and won't need to be updated/copied
#   - add the `prx_uri` and `prx_account_uri` to the podcast attributes
#   - add the `prx_uri` to the episodes
#   - update the episode page urls (not wordpress or libsyn or whatever anymore)

require 'prx_access'
require 'addressable/uri'

class FeederModel < ActiveRecord::Base
  self.abstract_class = true

  def self.status_values
    [ :started, :created, :processing, :complete, :error, :retrying, :cancelled ]
  end

  def self.feeder_db_connection
    {
      adapter: 'postgresql',
      encoding: 'unicode',
      pool: ENV['FEEDER_DB_POOL_SIZE'],
      user: ENV['FEEDER_DB_USER'],
      password: ENV['FEEDER_DB_PASSWORD'],
      host: ENV['FEEDER_DB_HOST'],
      port: ENV['FEEDER_DB_PORT'],
      database: ENV['FEEDER_DB_DATABASE']
    }
  end

  establish_connection(feeder_db_connection)
end

class Podcast < FeederModel
  has_many :episodes, -> { order('published_at desc') }
  has_many :podcast_images
end

class PodcastImage < FeederModel
  belongs_to :podcast
  enum status: status_values
end

class Episode < FeederModel
  belongs_to :podcast
  has_many :episode_images, -> { order('created_at DESC').complete }
  has_many :media_resources, -> { order('position ASC, created_at DESC').complete }
  scope :published, -> { where('published_at IS NOT NULL AND published_at <= now()') }

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

class FeederImporter
  include PRXAccess
  include Announce::Publisher

  attr_accessor :account_id, :user_id, :podcast_id
  attr_accessor :podcast, :series, :template, :distribution, :stories

  def debug
    TRUE
  end

  def initialize(account_id, user_id, podcast_id)
    self.account_id = account_id
    self.user_id = user_id
    self.podcast_id = podcast_id
    self.stories = []
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

    # Add images to the series
    podcast.podcast_images.each do |podcast_image|
      upload_url = copy_image(SecureRandom.uuid, image)
      purpose = image.type == 'FeedImage' ? Image::THUMBNAIL : Image::PROFILE
      image = series.images.create!(upload: upload_url, purpose: purpose)
      announce_image(image)
      podcast_image.update_attribute!(:original_url, image.public_url(version: 'original'))
    end

    # all the imports we plan to do from feeder -> cms have a single segment
    num_segments = 1

    self.template = series.audio_version_templates.create!(
      label: "Podcast Audio #{num_segments} #{'segment'.pluralize(num_segments)}",
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

  def create_stories
    podcast.episodes.each do |episode|
      create_story(episode)
    end
  end

  def create_story(episode)
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

    episode.media_files.each_with_index do |media_file, i|
      upload_url = copy_enclosure(episode, media_file)
      audio = version.audio_files.create!(label: "Segment #{i + 1}", upload: upload_url)
      announce_audio(audio)
      media_file.update_attribute!(:original_url, audio.fixerable_final_storage_url(true))
    end

    episode.episode_images.each do |episode_image|
      upload_url = copy_image(episode.guid, episode_image)
      image = story.images.create!(upload: upload_url)
      announce_image(image)
      episode_image.update_attribute!(:original_url, image.public_url(version: 'original'))
    end

    # create the story distribution
    episode_url = "#{feeder_root}/episodes/#{episode.guid}"
    story.distributions << StoryDistributions::EpisodeDistribution.create!(
      distribution: distribution,
      story: story,
      guid: episode.item_guid,
      url: episode_url
    )

    episode.update_attribute!(:prx_uri, "/api/v1/stories/#{story.id}")

    self.stories << story

    story
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
    to_path = "prod/#{guid}/#{from_path.split('/').last}"
    copy_file(from_path, to_path)
  end

  def copy_enclosure(episode, media_file)
    from_path = URI.parse(media_file['href']).path[1..-1]
    to_path = "prod/#{episode.id}/#{URI.parse(episode.links['enclosure'].href).path.split('/').last}"
    copy_file(from_path, to_path)
  end

  def copy_file(from_path, to_path)
    connection = AudioFileUploader.new.send(:storage).connection
    copy_options = {
      'x-amz-metadata-directive' => 'COPY',
      'x-amz-acl' => 'public-read'
    }
    puts "copy_object('prx-feed', '#{from_path}', 'prx-up', '#{to_path}', '#{copy_options.inspect}')"
    connection.copy_object('prx-feed', episode_file_path, 'prx-up', upload_path, copy_options) unless debug

    "https://prx-up.s3.amazonaws.com/#{to_path}"
  end

  def announce_image(image)
    announce('image', 'create', Api::Msg::ImageRepresenter.new(image).to_json)
  end

  def announce_audio(audio)
    announce('audio', 'create', Api::Msg::AudioFileRepresenter.new(audio).to_json)
  end
end
