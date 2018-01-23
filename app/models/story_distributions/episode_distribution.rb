# encoding: utf-8
require 'prx_access'
require 'announce'

class StoryDistributions::EpisodeDistribution < StoryDistribution
  include PRXAccess
  include Rails.application.routes.url_helpers
  include Announce::Publisher

  def distribute!
    super
    create_or_update_episode
  end

  def distributed?
    !url.blank?
  end

  def publish!
    super
    if story.published
      announce(:story, :publish, Api::Msg::StoryRepresenter.new(story).to_json)
    end
  end

  def published?
    published = false
    episode = get_episode

    if published_at_s = episode.attributes['published_at']
      published_at = DateTime.parse(published_at_s)
      published = published_at <= DateTime.now
    end
    published
  end

  def create_or_update_episode(attrs = {})
    episode = nil
    if url.blank?
      podcast = distribution.get_podcast
      episode = podcast.episodes.post(episode_attributes.merge(attrs))
      episode_url = URI.join(feeder_root, episode.links['self'].href).to_s
      raise 'Failed to get episode url on create' if episode_url.blank?
      update_attributes!(url: episode_url) if episode_url
    else
      episode = get_episode
      episode = episode.put(attrs)
    end
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
      clean_title: story.clean_title,
      subtitle: story.short_description,
      episode_number: identifier_to_i(story.episode_identifier),
      season_number: identifier_to_i(story.season_identifier),
      description: story.description_html,
      content: story.description_html,
      categories: story.tags,
      published_at: story.published_at,
      updated_at: story.updated_at,
      url: default_url(story)
    }
  end

  def identifier_to_i(i)
    return nil if i.nil?
    num = i.gsub(/[^\d]+/, ' ').strip.split.last
    if num.blank?
      nil
    else
      num.to_i
    end
  end

  def default_url(story)
    path = "#{story.class.name.underscore.pluralize}/#{story.id}"
    ENV['PRX_HOST'].nil? ? nil : "https://#{ENV['PRX_HOST']}/#{path}"
  end
end
