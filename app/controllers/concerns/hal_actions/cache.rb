module HalActions::Cache

  private

  def index_cache_path
    PagedCollection.new(
      filtered(paged(sorted(scoped(resources_base)))),
      request,
      item_class: self.class.resource_class,
      item_decorator: self.class.resource_representer
    ).cache_key
  end

  def show_cache_path
    show_resource.updated_at.utc.to_i
  end

  module ClassMethods
    def cache_api_action(action, options = {})
      options = cache_options.merge(options || {})
      cache_path_method = options.delete(:cache_path_method) || "#{action}_cache_path"
      options[:cache_path] = ->(c){ c.valid_params_for_action(action).merge({_c: self.send(cache_path_method) }) } if !options[:cache_path]

      caches_action(action, options)
    end

    def cache_options
      {compress: true, expires_in: 1.hour, race_condition_ttl: 30}
    end
  end
end
