# encoding: utf-8

class Authorization
  extend ActiveModel::Naming
  include RepresentedModel

  attr_accessor :token
  attr_reader :token_auth_accounts

  def initialize(token)
    @token = token
  end

  def id
    default_account.id
  end

  def default_account
    User.find(token.user_id).default_account
  end

  def token_auth_accounts
    token_ids = token.authorized_resources.try(:keys)
    @token_auth_accounts = Account.where(id: token_ids) if token_ids
  end

  def token_auth_stories
    Story.where(account_id: token_auth_accounts.try(:ids)) unless token_auth_accounts.nil?
  end

  def token_auth_series
    Series.where(account_id: token_auth_accounts.try(:ids)) unless token_auth_accounts.nil?
  end

  def authorized?(account)
    token_auth_accounts.include?(account)
  end

  def cache_key
    token_keys = (token.attributes || {}).keys.sort.map { |k| "#{k}:#{token.attributes[k]}" }
    key_components = ['c', self.class.model_name.cache_key]
    key_components << OpenSSL::Digest::MD5.hexdigest(token_keys.join(','))
    ActiveSupport::Cache.expand_cache_key(key_components)
  end

  def to_model
    self
  end

  def persisted?
    false
  end
end
