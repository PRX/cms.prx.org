# encoding: utf-8

require 'active_support/concern'

module ApiAuthenticated

  extend ActiveSupport::Concern

  included do
    before_filter :authenticate_user!
  end

  def authenticate_user!
    user_not_authorized unless current_user
  end

  def cache_show?
    false
  end

  def cache_index?
    false
  end

end
