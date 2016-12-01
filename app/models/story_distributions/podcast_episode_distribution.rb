# encoding: utf-8
require 'prx_access'

class StoryDistributions::PodcastEpisodeDistribution < StoryDistribution
  include PRXAccess
  include Rails.application.routes.url_helpers

  after_commit :add_episode_to_feeder, on: [:create]

  def add_episode_to_feeder
    return unless url.blank?
    podcast = distribution.get_podcast
    episode = podcast.episodes.post(episode_attributes)
    episode_url = URI.join(feeder_root, episode.links['self'].href).to_s
    self.update_column(:url, episode_url) if episode_url
  end

  def episode_attributes
    {
      prx_uri: api_story_path(story)
    }
  end
end
