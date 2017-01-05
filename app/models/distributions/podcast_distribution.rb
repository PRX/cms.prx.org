# encoding: utf-8
require 'prx_access'

class Distributions::PodcastDistribution < Distribution
  include PRXAccess
  include Rails.application.routes.url_helpers

  def distribute!
    super
    add_podcast_to_feeder
  end

  def story_distribution_class
    StoryDistributions::EpisodeDistribution
  end

  def add_podcast_to_feeder
    return unless url.blank?
    client = api(root: feeder_root, account: account.id)
    podcast = client.podcasts.first.post(podcast_attributes)
    podcast_url = URI.join(feeder_root, podcast.links['self'].href).to_s
    raise 'Failed to get podcast url on create' if podcast_url.blank?
    update_attributes!(url: podcast_url)
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
      attrs[:summary] = owner.description
      if owner.images.profile
        attrs[:itunes_image] = { url: owner.images.profile.public_url(version: 'original') }
      end

      if owner.images.thumbnail
        attrs[:feed_image] = { url: owner.images.thumbnail.public_url(version: 'original') }
      end
    end

    attrs
  end
end
