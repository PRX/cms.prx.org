# encoding: utf-8
class Api::BaseController < ApplicationController

  protect_from_forgery with: :null_session

  before_action :set_accepts

  include ApiVersioning
  include HalActions
  include Roar::Rails::ControllerAdditions
  include ActionBack::ControllerAdditions

  # respond to hal or json, but always returns application/hal+json
  respond_to :hal, :json

  allow_params :show, :zoom
  allow_params :index, [:page, :zoom]

  cache_api_action :show

  cache_api_action :index

  caches_action :entrypoint, cache_path: ->(c){ {_c: Api.version(api_version).cache_key } }

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def entrypoint
    respond_with Api.version(api_version)
  end

  def current_user
    @current_user ||= if prx_auth_token
      User.find_by(id: prx_auth_token.user_id)
    end
  end

  def current_user=(user)
    @current_user = user
  end

  private

  def set_accepts
    request.format = :json if request.format == Mime::HTML
  end

  def user_not_authorized
    render json: { error: 'You are not authorized to perform this action' },
                   status: 401
  end
end
