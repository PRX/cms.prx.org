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

require 'prx_access'
require 'addressable/uri'

class FeederImporter
  include PRXAccess
  include Announce::Publisher

  attr_accessor :account_id, :user_id, :feeder_podcast_url
  attr_accessor :podcast, :series, :template, :distribution

  def debug
    TRUE
  end

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

    version = story.audio_versions.create!(
      audio_version_template: template,
      explicit: episode.attributes[:explicit]
    )

    Array(episode.attributes[:media]).each do |media_file|
      upload_url = copy_file(episode, media_file)
      audio = version.audio_files.create!(label: "Segment #{i + 1}", upload: upload_url)
      announce_audio(audio)
    end

    story
  end

  def copy_file(episode, media_file)
    episode_file_path = URI.parse(media_file['href']).path[1..-1]
    upload_path = "prod/#{episode.id}/#{URI.parse(episode.links['enclosure'].href).path.split('/').last}"

    connection = AudioFileUploader.new.send(:storage).connection
    # copy_object(source_bucket_name, source_object_name, target_bucket_name, target_object_name, options = {}) ⇒ Object
    copy_options = {
      'x-amz-metadata-directive' => 'COPY',
      'x-amz-acl' => 'public-read'
    }

    puts "copy_object('prx-feed', '#{episode_file_path}', 'prx-up', '#{upload_path}', '#{copy_options.inspect}')"
    connection.copy_object('prx-feed', episode_file_path, 'prx-up', upload_path, copy_options) unless debug

    "https://prx-up.s3.amazonaws.com/#{upload_path}"
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
