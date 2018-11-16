# encoding: utf-8

require 'hal_api/rails'

class Api::BaseController < ApplicationController
  include HalApi::Controller

  def self.responder
    Api::ApiResponder
  end

  include Pundit
  include ApiVersioning
  include ApiFiltering
  include ApiSorting
  include ResourceCallbacks
  include ChildResource
  include PolymorphicResource
  include AnnounceActions

  protect_from_forgery with: :null_session

  allow_params :show, [:api_version, :format, :zoom]
  allow_params :index, [:api_version, :format, :page, :per, :zoom, :filters, :sorts]

  sort_params default: { updated_at: :desc }, allowed: [:id, :created_at, :updated_at]

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

  def authorization
    Authorization.new(prx_auth_token) if prx_auth_token
  end

  def authenticate_user!
    user_not_authorized unless current_user
  end

  def filtered(arel)
    keys = self.class.resources_params || []
    where_hash = params.slice(*keys)
    if where_hash.key?('story_id')
      where_hash['piece_id'] = where_hash.delete('story_id')
    end
    where_hash = where_hash.permit(where_hash.keys)
    arel = arel.where(where_hash) unless where_hash.blank?
    arel
  end

  private

  def respond_with_error(exception)
    return validation_failed exception if exception.instance_of? ActiveRecord::RecordInvalid

    super
  end

  def user_not_authorized(exception = nil)
    message = { status: 401, message: 'You are not authorized to perform this action' }
    if exception && Rails.configuration.try(:consider_all_requests_local)
      message[:backtrace] = exception.backtrace
    end
    render json: message, status: 401
  end

  def validation_failed(exception = nil)
    message = { status: 409, message: exception.message }
    if exception && Rails.configuration.try(:consider_all_requests_local)
      message[:backtrace] = exception.backtrace
    end
    render json: message, status: 409
  end

  def wrap_in_transaction
    ActiveRecord::Base.transaction do
      yield
    end
  end
end
