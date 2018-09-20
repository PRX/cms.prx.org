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
require 'tempfile'
require 'digest/sha2'
require 'fileutils'
require 'excon'

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
  has_many :episodes, -> { where('deleted_at IS NULL').order('published_at desc') }
  has_one :itunes_image
  has_one :feed_image
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

  def contains_video?
    media_resources.any? { |mr| mr.mime_type.starts_with?('video/') }
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
  MAX_FILENAME_LENGTH = 160
  MAX_EXTENSION_LENGTH = 6

  include Announce::Publisher
  include PRXAccess
  include ImportUtils

  attr_accessor :account_id, :user_id, :podcast_id, :set_episode_urls
  attr_accessor :podcast, :series, :audio_template, :distribution, :stories, :video_template

  def initialize(account_id, user_id, podcast_id, set_episode_urls = false)
    self.account_id = account_id
    self.user_id = user_id
    self.podcast_id = podcast_id
    self.stories = []
    self.set_episode_urls = set_episode_urls
  end

  def import
    retrieve_podcast
    lock_podcast!
    create_series unless find_series
    create_stories
    update_podcast
    remind_to_unlock(podcast.title)
  end

  def retrieve_podcast
    self.podcast = Podcast.find(podcast_id)
  end

  def lock_podcast!
    podcast.update!(locked: true)
  end

  def find_series
    podcast_url = "#{feeder_root}/podcasts/#{podcast_id}"
    self.distribution = Distributions::PodcastDistribution.find_by_url(podcast_url)
    self.series = distribution.owner if distribution
    series
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

    create_series_image(podcast.itunes_image, Image::PROFILE)
    create_series_image(podcast.feed_image, Image::THUMBNAIL)

    # all the imports we plan to do from feeder -> cms have a single segment
    num_segments = 1

    episode = podcast.episodes.first
    if episode.media_resources
      num_segments = [episode.media_resources.count, num_segments].max
    end

    contains_video = podcast.episodes.any?(&:contains_video?)

    self.audio_template = series.audio_version_templates.create!(
      label: "Podcast Audio #{num_segments} #{'segment'.pluralize(num_segments)}",
      content_type: AudioFile::MP3_CONTENT_TYPE,
      segment_count: num_segments,
      promos: false,
      length_minimum: 0,
      length_maximum: 0
    )

    if contains_video
      self.video_template = series.audio_version_templates.create!(
        label: "Podcast Video #{num_segments} #{'segment'.pluralize(num_segments)}",
        content_type: AudioFile::VIDEO_CONTENT_TYPE,
        segment_count: num_segments,
        promos: false,
        length_minimum: 0,
        length_maximum: 0
      )
    end

    templates = [video_template, audio_template].compact
    distro_templates = []
    templates.each do |t|
      num_segments.times do |x|
        num = x + 1
        t.audio_file_templates.create!(
          position: num,
          label: "Segment #{num}",
          length_minimum: 0,
          length_maximum: 0
        )
      end
      distro_templates << DistributionTemplate.new(audio_version_template: t)
    end

    self.distribution = Distributions::PodcastDistribution.create!(
      url: "#{feeder_root}/podcasts/#{podcast_id}",
      distributable: series,
      distribution_templates: distro_templates,
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
      create_story(episode) unless find_story(episode)
    end
  end

  def find_story(episode)
    episode_url = "#{feeder_root}/episodes/#{episode.guid}"
    StoryDistributions::EpisodeDistribution.find_by_url(episode_url)
  end

  def template_for_episode(episode)
    episode.contains_video? ? video_template : audio_template
  end

  def episode_description(episode)
    attrname = %i(content summary description subtitle title).find { |d| !episode[d].blank? }
    episode[attrname]
  end

  def create_story(episode)
    # puts "episode.categories: #{episode.categories.inspect}"
    attrs = {
      app_version: PRX::APP_VERSION,
      creator_id: user_id,
      account_id: account_id,
      title: episode.title,
      short_description: episode.subtitle,
      description_html: episode_description(episode),
      tags: episode.categories,
      published_at: episode.published_at,
      released_at: episode.published_at,
    }
    story = series.stories.create!(attrs)

    version = story.audio_versions.create!(
      audio_version_template: template_for_episode(episode),
      label: 'Podcast Audio',
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
      source_url: nil,
      explicit: explicit(podcast.explicit)
    )
  end

  def copy_image(guid, image)
    from_path = URI.parse(image.url).path[1..-1]
    to_path = "#{short_env}/#{guid}/#{from_path.split('/').last}"
    if image.url =~ /f.prxu.org/
      copy_file(from_path, to_path)
    else
      upload_file(image.url, to_path)
    end
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

    if ['production', 'staging'].include?(ENV['RAILS_ENV'])
      connection.copy_object('prx-feed', from_path, 'prx-up', to_path, options)
    end

    "https://prx-up.s3.amazonaws.com/#{to_path}"
  end

  def upload_file(from_url, to_path)
    file_name = File.basename(to_path)
    connection = AudioFileUploader.new.send(:storage).connection
    options = {
      'Content-Disposition' => "attachment; filename=\"#{file_name}\"",
      'Cache-Control' => 'max-age=86400',
      'x-amz-acl' => 'public-read'
    }

    tmpfile = download_file(from_url)

    if ['production', 'staging'].include?(ENV['RAILS_ENV'])
      connection.put_object('prx-up', to_path, tmpfile, options)
    end

    "https://prx-up.s3.amazonaws.com/#{to_path}"
  end

  def create_temp_file(base_file_name = nil, bin_mode = true)
    file_name = File.basename(base_file_name)
    file_name = Digest::SHA256.hexdigest(base_file_name) if file_name.length > MAX_FILENAME_LENGTH
    file_ext = File.extname(base_file_name)[0, MAX_EXTENSION_LENGTH]

    FileUtils.mkdir_p(tmp_dir)

    Tempfile.new([file_name, file_ext], tmp_dir).tap { |t| t.binmode if bin_mode }
  end

  def close_temp_file(temp_file)
    if temp_file
      temp_file.close
      File.unlink(temp_file)
    end
  rescue StandardError
    nil
  end

  def tmp_dir
    './tmp/feeder_import'
  end

  def download_file(uri, limit = 10)
    temp_file = nil
    try_count = 0
    file_downloaded = false

    prior_remaining, prior_total = 0
    streamer = lambda do |chunk, remaining_bytes, total_bytes|
      if (remaining_bytes.to_i > prior_remaining) || (total_bytes.to_i != prior_total) || !temp_file
        close_temp_file(temp_file)
        temp_file = create_temp_file(uri.to_s)
      end

      prior_remaining = remaining_bytes.to_i
      prior_total = total_bytes.to_i
      temp_file.write(chunk)
    end

    while !file_downloaded && try_count < limit
      try_count += 1
      begin
        close_temp_file(temp_file)

        Excon.get(uri.to_s, {
          idempotent: false,
          retry_limit: 0,
          omit_default_port: true,
          ssl_verify_peer: ENV['SSL_VERIFY_PEER'],
          response_block: streamer,
          middlewares: Excon.defaults[:middlewares] + [Excon::Middleware::RedirectFollower]
        })

        temp_file.fsync
        file_downloaded = true
      rescue StandardError => err
        puts "File failed to be retrieved: '#{uri}': #{err.message}"
      end
      sleep(1)
    end

    unless file_downloaded
      raise "HTTP Download #{uri}: did not complete"
    end

    if prior_total.positive? && temp_file.size != prior_total
      raise "HTTP Download #{uri}: #{temp_file.size} is not the expected size: #{prior_total}"
    end

    unless temp_file.size
      raise "HTTP Download #{uri}: Zero length file downloaded"
    end

    temp_file
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
