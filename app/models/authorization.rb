# encoding: utf-8

class Authorization
  attr_accessor :token
  attr_reader :token_auth_accounts

  def initialize(token)
    @token = token
    get_authorized_resources
  end

  def get_authorized_resources
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
end
