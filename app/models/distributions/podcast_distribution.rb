# encoding: utf-8
require 'prx_access'

class Distributions::PodcastDistribution < Distribution
  include PRXAccess
  include Rails.application.routes.url_helpers

  def distribute
    super
    add_podcast_to_feeder
  end

  def add_podcast_to_feeder
    return unless url.blank?
    client = api(root: feeder_root, account: account.id)
    podcast = client.podcasts.first.post(podcast_attributes)
    podcast_url = URI.join(feeder_root, podcast.links['self'].href).to_s
    self.update_column(:url, podcast_url) if podcast_url
  end

  def get_podcast
    api(root: feeder_root, account: account.id).tap { |a| a.href = url }.get
  end

  def podcast_attributes
    {
      prx_uri: polymorphic_url(['api', owner], only_path: true),
      prx_account_uri: api_account_path(account)
    }
  end
end
