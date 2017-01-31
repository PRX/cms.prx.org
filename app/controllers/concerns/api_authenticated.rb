# encoding: utf-8

require 'active_support/concern'

module ApiAuthenticated

  extend ActiveSupport::Concern

  included do
    before_filter :authenticate_user!, :get_authorized_resources
  end

  def authenticate_user!
    user_not_authorized unless current_user
  end

  def get_authorized_resources
    if prx_auth_token.authorized_resources
      current_user.approved_accounts ||= Account.where({ id: prx_auth_token.authorized_resources.keys })
    end
  end

  def cache_show?
    false
  end

  def cache_index?
    false
  end

end
