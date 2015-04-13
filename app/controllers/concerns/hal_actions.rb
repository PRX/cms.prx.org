# encoding: utf-8

require 'active_support/concern'

# expects underlying model to have filename, class, and id attributes
module HalActions

  extend ActiveSupport::Concern

  def show_cache_path
    show_resource.updated_at.utc.to_i
  end

  def show
    respond_with show_resource, show_options
  end

  def create
    self.resource = consume!(resource)
    authorize resource
    resource.save!
    respond_with show_resource, show_options
  end

  def update
    self.resource = consume!(resource)
    authorize resource
    resource.save!
    respond_with show_resource, show_options
  end

  def show_resource
    raise ActiveRecord::RecordNotFound.new unless resource
    resource.tap { |r| r.is_root_resource = true }
  end

  def resource
    instance_variable_get("@#{resource_name}") || self.resource = if params[:id]
      self.class.resource_class.find(params[:id].to_i)
    else
      self.class.resource_class.new if request.put? || request.post?
    end
  end

  def resource=(res)
    instance_variable_set("@#{resource_name}", res)
  end

  def resource_name
    self.class.resource_class.name.underscore
  end

  def show_options
    valid_params_for_action(:show).tap do |o|
      o[:_keys] = o.keys
      if self.class.resource_representer
        o[:represent_with] = self.class.resource_representer
      end
    end
  end

  def valid_params_for_action(action)
    p = params.slice(*self.class.valid_params_list(action)) || {}
    p[:zoom] = zoom_param if zoom_param
    p
  end

  def zoom_param
    @zoom_param ||= ->() {
      zp = params[:zoom]
      return nil if zp.blank?
      zp.split(',').map(&:strip).compact.sort
    }.call
  end

  def index_cache_path
    index_resources = self.try(:resources_base) || resources
    PagedCollection.new(
      decorate_query(index_resources),
      request,
      item_class: self.class.resource_class,
      item_decorator: self.class.resource_representer
    ).cache_key
  end

  def index
    respond_with index_collection, index_options
  end

  def index_collection
    PagedCollection.new(
      decorate_query(resources),
      request,
      item_class: self.class.resource_class,
      item_decorator: self.class.resource_representer
    )
  end

  def resources
    instance_variable_get("@#{resources_name}") ||
    self.resources = self.class.resource_class
  end

  def resources=(res)
    instance_variable_set("@#{resources_name}", res)
  end

  def resources_name
    resource_name.pluralize
  end

  def decorate_query(res)
    res = with_sorting(res)
    res = with_paging(res)
    res = with_params(res)
    res
  end

  def with_sorting(arel)
    arel.order(id: :desc)
  end

  def with_paging(arel)
    arel.page(params[:page]).per(params[:per])
  end

  def with_params(arel)
    keys = self.class.resources_params || []
    where_hash = params.slice(*keys)
    where_hash['piece_id'] = where_hash.delete('story_id') if where_hash.key?('story_id')
    where_hash = where_hash.permit(where_hash.keys)
    arel = arel.where(where_hash) unless where_hash.blank?
    arel
  end

  def index_options
    o = valid_params_for_action(:index)
    o[:_keys] = o.keys
    o
  end

  module ClassMethods

    attr_accessor :resource_class, :resources_params, :resource_representer, :valid_params

    def resource_class
      @resource_class ||= self.controller_name.classify.constantize
    end

    def filter_resources_by(*rparams)
      self.resources_params = rparams
    end

    def represent_with(representer_class)
      self.resource_representer = representer_class
    end

    def allow_params(action, *params)
      self.valid_params ||= {}
      valid_params[action.to_sym] = Array(params).flatten
    end

    def valid_params_list(action)
      (valid_params || {})[action.to_sym]
    end

    def cache_options
      {compress: true, expires_in: 1.hour, race_condition_ttl: 30}
    end

    def cache_api_action(action, options = {})
      options = cache_options.merge(options || {})
      cache_path_method = options.delete(:cache_path_method) || "#{action}_cache_path"
      options[:cache_path] = ->(c){ c.valid_params_for_action(action).merge({_c: self.send(cache_path_method) }) } if !options[:cache_path]

      caches_action(action, options)
    end
  end
end
