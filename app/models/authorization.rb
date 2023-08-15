# encoding: utf-8

class Authorization
  extend ActiveModel::Naming
  include HalApi::RepresentedModel

  attr_accessor :token

  delegate :resources, to: :token

  def initialize(token)
    @token = token
  end

  def id
    default_account.id
  end

  def feeder_ui_access
    if (token.resources(:feeder, :read_private) - token_auth_account_ids).any?
      host = ENV["FEEDER_HOST"]
      if host.present?
        host.starts_with?("http") ? host : "https://#{host}"
      else
        "https://feeder.prx.org"
      end
    end
  end

  def default_account
    User.find(token.user_id).default_account
  end

  def account_ids(scope = nil)
    token.resources(scope).map(&:to_i)
  end

  def token_auth_account_ids
    account_ids(:read_private)
  end

  def token_auth_accounts
    @token_auth_accounts ||= Account.where(id: token_auth_account_ids).
                             left_joins(:address, :image, :opener).
                             includes(:address, :image, :opener)
  end

  def token_auth_stories
    @token_auth_stories ||= Story.where(account_id: account_ids(:read_private))
  end

  def token_auth_series
    @token_auth_series ||= Series.where(account_id: account_ids(:read_private))
  end

  def podcast_imports
    @podcast_imports ||= PodcastImport.where(account_id: account_ids(:read_private))
  end

  def cache_key
    key_components = ['c', self.class.model_name.cache_key]
    key_components << OpenSSL::Digest::MD5.hexdigest(token.resources(:read_private).sort.join(' '))
    ActiveSupport::Cache.expand_cache_key(key_components)
  end

  def to_model
    self
  end

  def persisted?
    false
  end
end
