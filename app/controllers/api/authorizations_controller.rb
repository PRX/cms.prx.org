# encoding: utf-8

class Api::AuthorizationsController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :set_accepts

  include ApiVersioning
  include HalActions
  include Roar::Rails::ControllerAdditions
  include ActionBack::ControllerAdditions

  respond_to :hal, :json
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def set_accepts
    request.format = :json if request.format == Mime::HTML
  end

  def user_not_authorized
    message = { error: 'You are not authorized to perform this action' }
    render json: message, status: 401
  end

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
