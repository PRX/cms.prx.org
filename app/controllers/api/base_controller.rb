class Api::BaseController < ApplicationController

  protect_from_forgery with: :null_session

  after_filter :set_access_control_headers

  class << self
    attr_accessor :understood_api_versions
    def api_versions(*versions)
      self.understood_api_versions = versions.map(&:to_s)
      before_filter :check_api_version
    end
  end

  include Roar::Rails::ControllerAdditions

  respond_to :json

  def entrypoint
    respond_with Api.version(api_version)
  end

  private

  def set_access_control_headers 
    headers['Access-Control-Allow-Origin'] = '*' 
    headers['Access-Control-Request-Method'] = '*'
  end

  def api_version
    params[:api_version]
  end

  def check_api_version
    unless self.class.understood_api_versions.include?(api_version)
      render status: :not_acceptable, file: 'public/404.html'
      false
    end
  end
end