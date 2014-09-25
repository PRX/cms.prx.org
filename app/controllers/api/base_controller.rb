# encoding: utf-8

class Api::BaseController < ApplicationController

  protect_from_forgery with: :null_session

  before_action :set_accepts

  include ApiVersioning
  include HalActions
  include Roar::Rails::ControllerAdditions

  # respond to hal or json, but always returns application/hal+json
  respond_to :hal, :json

  allow_params :show, :zoom
  allow_params :index, [:page, :zoom]

  cache_api_action :show

  cache_api_action :index

  caches_action :entrypoint, cache_path: ->(c){ {_c: Api.version(api_version).cache_key } }

  def entrypoint
    respond_with Api.version(api_version)
  end

  def current_user
    if request.env['prx.auth']
      User.find(request.env['prx.auth']['sub'])
    end
  end

  private

  def set_accepts
    request.format = :json if request.format == Mime::HTML
  end

end
