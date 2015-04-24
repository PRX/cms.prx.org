# encoding: utf-8

class Api::AuthorizationsController < Api::BaseController
  def resource
    Authorization.new(User.find(prx_auth_token.user_id))
  end

  def resources
    Authorization.new(User.find(prx_auth_token.user_id)).accounts
  end

  def index_collection
    PagedCollection.new(
      decorate_query(resources),
      request,
      item_class: Account,
      item_decorator: Api::Min::AccountRepresenter
    )
  end
end
