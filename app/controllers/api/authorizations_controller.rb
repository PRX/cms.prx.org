# encoding: utf-8

class Api::AuthorizationsController < Api::BaseController
  private
  def resource
    @auth ||= Authorization.new(user)
  end

  def resources
    @accounts ||= resource.accounts
  end

  def index_collection
    PagedCollection.new(
      decorate_query(resources),
      request,
      item_class: Account,
      item_decorator: Api::Min::AccountRepresenter
    )
  end

  def user
    @user ||= User.find(prx_auth_token.user_id)
  end
end
