class Api::BaseController < ApplicationController
  protect_from_forgery with: :null_session

  class << self

    attr_accessor :understood_api_versions, :resource_class, :resources_params, :resource_representer
    def api_versions(*versions)
      self.understood_api_versions = versions.map(&:to_s)
      before_filter :check_api_version
    end

    def resource_class
      @resource_class ||= self.controller_name.classify.constantize
    end

    def filter_resources_by(*rparams)
      self.resources_params = rparams
    end

    def represent_with(representer_class)
      self.resource_representer = representer_class
    end

  end

  include Roar::Rails::ControllerAdditions
  respond_to :json

  def entrypoint
    respond_with Api.version(api_version)
  end

  def show
    respond_with resource, show_options
  end

  def resource
    instance_variable_get("@#{resource_name}") || begin
      res = self.class.resource_class.find(params[:id].to_i)
      instance_variable_set("@#{resource_name}", res)
    end
  end

  def resource_name
    self.class.resource_class.name.underscore
  end

  def show_options
    options = {}
    options[:represent_with] = self.class.resource_representer if self.class.resource_representer
    options
  end

  def index
    respond_with collection
  end

  def collection
    PagedCollection.new(with_params(self.class.resources_params, resources), request, item_class: self.class.resource_class, item_decorator: self.class.resource_representer )
  end

  def resources
    instance_variable_get("@#{resources_name}") || begin
      res = self.class.resource_class.order(id: :desc).page(params[:page])
      instance_variable_set("@#{resources_name}", res)
    end
  end

  def resources_name
    resource_name.pluralize
  end

  def with_params(keys, arel)
    where_hash = params.slice(keys || [])
    where_hash[:piece_id] = where_hash.delete(:story_id) if where_hash.key?(:story_id)
    arel = arel.where(where_hash) unless where_hash.blank?
    arel
  end

  private

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