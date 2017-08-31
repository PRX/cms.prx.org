require 'prx_access'
require 'addressable/uri'

class FeederImporter
  include PRXAccess

  attr_accessor :account_id, :user_id, :feeder_podcast_url
  attr_accessor :podcast

  def initialize(account_id, user_id, feeder_podcast_url)
    self.account_id = account_id
    self.user_id = user_id
    self.feeder_podcast_url = feeder_podcast_url
  end

  def import
    self.podcast = retrieve_podcast(account_id, feeder_podcast_url)
    self.series = create_series
  end

  def create_series(podcast = podcast)
    attrs = {
      title: podcast.title,
      account_id: account_id,
      creator_id: user_id,
      short_description: podcast.attributes[:subtitle],
      description_html: podcast.attributes[:description]
    }
    Series.create!(attrs)
  end

  def retrieve_podcast
    api(root: feeder_root, account: account_id).tap { |a| a.href = feeder_podcast_url }.get
  end
end
