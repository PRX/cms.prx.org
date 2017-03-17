# encoding: utf-8
require 'prx_access'

class StoryDistributions::EpisodeDistribution < StoryDistribution
  include PRXAccess
  include Rails.application.routes.url_helpers

  def distribute!
    super
    add_episode_to_feeder
  end

  def add_episode_to_feeder(create_attributes = {})
    return unless url.blank?
    podcast = distribution.get_podcast
    post_attributes = episode_attributes.merge(create_attributes)
    post_attributes['url'] = default_url(story) if create_attributes.empty?
    episode = podcast.episodes.post(post_attributes)
    episode_url = URI.join(feeder_root, episode.links['self'].href).to_s
    raise 'Failed to get episode url on create' if episode_url.blank?
    update_attributes!(url: episode_url) if episode_url
    episode
  end

  def get_episode
    api(root: feeder_root, account: distribution.account.id).tap { |a| a.href = auth_url }.get
  end

  def auth_url
    result = url
    if result && !result.match(/authorization/)
      result = result.gsub('/episodes/', '/authorization/episodes/')
    end
    result
  end

  def episode_attributes
    {
      prx_uri: api_story_path(story),
      title: story.title,
      subtitle: story.short_description,
      description: story.description_html,
      content: story.description_html,
      categories: story.tags,
      published_at: story.published_at,
      updated_at: story.updated_at
    }
  end

  def default_url(story)
    path = "#{story.class.name.underscore.pluralize}/#{story.id}"
    ENV['PRX_HOST'].nil? ? nil : "https://#{ENV['PRX_HOST']}/#{path}"
  end
end
