# encoding: utf-8

class Api::BaseController < ApplicationController
  include Pundit

  protect_from_forgery with: :null_session

  before_action :set_accepts

  include ApiVersioning
  include HalActions
  include AnnounceActions
  include Roar::Rails::ControllerAdditions

  # respond to hal or json, but always returns application/hal+json
  respond_to :hal, :json

  allow_params :show, :zoom
  allow_params :index, [:page, :per, :zoom]

  cache_api_action :show, if: :cache_show?
  cache_api_action :index, if: :cache_index?

  caches_action :entrypoint, cache_path: ->(_c) { { _c: Api.version(api_version).cache_key } }

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def entrypoint
    respond_with Api.version(api_version)
  end

  def cache_show?
    true
  end

  def cache_index?
    true
  end

  def options
    head :no_content
  end

  def pundit_user
    prx_auth_token
  end

  def current_user
    @current_user ||= if prx_auth_token
      User.find(prx_auth_token.user_id)
    end
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def current_user=(user)
    @current_user = user
  end

  private

  def set_accepts
    request.format = :json if request.format == Mime::HTML
  end

  def user_not_authorized
    message = { error: 'You are not authorized to perform this action' }
    render json: message, status: 401
  end
end
