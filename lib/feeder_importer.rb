# import script for a podcast live in feeder & dovetail
require 'prx_access'

class FeederImporter
  include PRXAccess

  attr_accessor :cms_account_path, :feeder_podcast_path

  def initialize(account, podcast)
    self.cms_account_path = account
    self.feeder_podcast_path = podcast
  end

  def import
    # Query the feeder podcast, get info needed to create a series
    podcast = get_feeder_podcast

    # Create the series
    series = create_series(podcast)

    # Create the distribution
    create_distribution(podcast, series)

    # Create the episodes
    response = podcast.episodes.get
    create_episodes(response['_embedded']['prx:items'])
    while response.links['next']
      response = podcast.episodes.get
      create_episodes(response['_embedded']['prx:items'])
    end
  end

  def create_stories(episodes)
    episodes.each { |e| create_story(e) }
  end

  def create_story(episode)
    # create the story
    #   distribution should be auto created

    # add the audio

    # add the image

  end

  def create_series(podcast)
    series_attributes = {
      title: podcast.title,
      short_description: podcast.subtitle,
      description: podcast.description
    }

    client = api(root: cms_root, account: cms_account_path).get
    series = client.series.first.post(series_attributes)

    # Add an image to the series
    image_url = podcast.attributes['itunes_image']['url'] || podcast.attributes['feed_image']['url']
    series.create_image.post(upload: image_url)

    series
  end

  def create_distribution(podcast, series)
    podcast_url = URI.join(feeder_root, podcast.links['self'].href).to_s
    series.distributions.post(kind: 'podcast', url: podcast_url)
  end

  def get_feeder_podcast(podcast_path = feeder_podcast_path)
    api(root: feeder_root, account: cms_account_path).tap { |a| a.href = podcast_path }.get
  end
end
