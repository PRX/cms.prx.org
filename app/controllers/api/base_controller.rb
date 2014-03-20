# encoding: utf-8

class Api::BaseController < ApplicationController

  protect_from_forgery with: :null_session

  include ApiVersioning
  include HalActions
  include Roar::Rails::ControllerAdditions

  # respond to hal or json, but always returns application/hal+json
  respond_to :hal, :json

  allow_params :show, :zoom
  allow_params :index, [:page, :zoom]

  caches_action :show, cache_path: ->(c){
    c.valid_params_for_action(:show).merge({_c: show_cache_path })
  }

  caches_action :index, cache_path: ->(c){
    c.valid_params_for_action(:index).merge({_c: index_cache_path })
  }

  def entrypoint
    respond_with Api.version(api_version)
  end

end
