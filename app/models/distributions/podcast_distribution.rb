require 'prx_access'

module Distributions
  class PodcastDistribution < ::Distribution
    include PRXAccess
    include Rails.application.routes.url_helpers

    # after_commit :add_podcast_to_feeder, on: [:create]

    def add_podcast_to_feeder
      client = api(root: feeder_root, account: account.id)
      podcast = client.podcasts.first.post(podcast_attributes)
      podcast_url = URI.join(feeder_root, podcast.links['self'].href).to_s
      self.update_attribute(:url, podcast_url) if podcast_url
    end

    def podcast_attributes
      {
        prx_uri: polymorphic_url(['api', owner], only_path: true),
        prx_account_uri: api_account_path(account)
      }
    end
  end
end
