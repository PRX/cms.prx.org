# encoding: utf-8
require 'hal_api/rails'

class Api::BaseController < ApplicationController
  include HalApi::Controller
  include Pundit
  include ApiVersioning
  include ApiFiltering
  include AnnounceActions

  protect_from_forgery with: :null_session

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

  def user_not_authorized
    message = { error: 'You are not authorized to perform this action' }
    render json: message, status: 401
  end
end
