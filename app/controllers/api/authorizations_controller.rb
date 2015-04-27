# encoding: utf-8

class Api::AuthorizationsController < Api::BaseController
  def resource
    Authorization.new(User.find(prx_auth_token.user_id))
  end

  def resources_base
    Authorization.new(User.find(prx_auth_token.user_id)).accounts
  end

  def index_collection
    super.tap do |collection|
      collection.options[:item_class] = Account
      collection.options[:item_decorator] = Api::Min::AccountRepresenter
    end
  end
end
