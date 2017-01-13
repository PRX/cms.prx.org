# encoding: utf-8
require 'prx_access'

class StoryDistributions::EpisodeDistribution < StoryDistribution
  include PRXAccess
  include Rails.application.routes.url_helpers

  def distribute!
    super
    add_episode_to_feeder
  end

  def add_episode_to_feeder
    return unless url.blank?
    podcast = distribution.get_podcast
    episode = podcast.episodes.post(episode_attributes)
    episode_url = URI.join(feeder_root, episode.links['self'].href).to_s
    raise 'Failed to get episode url on create' if episode_url.blank?
    update_attributes!(url: episode_url) if episode_url
  end

  def episode_attributes
    {
      prx_uri: api_story_path(story),
      title: story.title,
      subtitle: Sanitize.fragment(story.short_description || '').strip,
      description: Sanitize.fragment(story.description || '').strip,
      summary: story.description,
      content: story.description,
      categories: story.tags,
      published_at: story.published_at,
      updated_at: story.updated_at
    }
  end
end
