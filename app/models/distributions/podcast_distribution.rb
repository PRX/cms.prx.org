# encoding: utf-8

require 'prx_access'
require 'announce'

class Distributions::PodcastDistribution < Distribution
  include PRXAccess
  include Rails.application.routes.url_helpers
  include Announce::Publisher

  def distribute!
    super
    create_or_update_podcast!
  end

  def distributed?
    !url.blank?
  end

  def publish!
    super
    if distributable && distributable.is_a?(Series)
      announce(:series, :update, Api::Msg::SeriesRepresenter.new(distributable).to_json)
    end
  end

  def published?
    published = false
    podcast = get_podcast

    if published_at_s = podcast.attributes['published_at']
      published_at = DateTime.parse(published_at_s)
      published = published_at <= DateTime.now
    end
    published && stories_published?
  end

  def stories_published?
    # if the story isn't published, then no need to check the distro.
    # if the story is published, then the distro needs to be published to.
    story_distributions.all? { |sd| sd.distributed? && (!sd.story.published? || sd.published?) }
  end

  def story_distribution_class
    StoryDistributions::EpisodeDistribution
  end

  def create_or_update_podcast!(attrs = {})
    podcast = nil
    if url.blank?
      client = api(root: feeder_root, account: account.id)
      podcast = client.podcasts.first.post(podcast_attributes.merge(attrs))
      podcast_url = URI.join(feeder_root, podcast.links['self'].href).to_s
      raise 'Failed to get podcast url on create' if podcast_url.blank?
      update_attributes!(url: podcast_url)
    else
      podcast = get_podcast
      podcast = podcast.put(attrs)
    end
    podcast
  end

  def get_podcast
    api(root: feeder_root, account: account.id).tap { |a| a.href = url }.get
  end

  def podcast_attributes
    attrs = {
      prx_uri: polymorphic_url(['api', owner], only_path: true),
      prx_account_uri: api_account_path(account),
      published_at: Time.now
    }

    if owner.is_a?(Series)
      attrs[:title] = owner.title
      attrs[:subtitle] = owner.short_description
      attrs[:description] = owner.description
    end

    attrs
  end
end
