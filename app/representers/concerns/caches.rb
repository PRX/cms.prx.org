# encoding: utf-8

require 'active_support/concern'

# expects underlying model to have filename, class, and id attributes
module Caches

  extend ActiveSupport::Concern

  # Pass in an option for the format this is going `to_`
  # used in caching the final string format of the obj
  # rather than the intermediary `Hash`, a modest accelerant
  def to_json(options={})
    options[:to_] = :json
    super(options)
  end

  def create_representation_with(doc, options, format)
    cache.fetch(cache_key(represented, options), cache_options) do
      response = super(doc, options, format)
      response = Caches::SerializedJson.new(JSON.dump(response)) if (options[:to_] == :json)
      response
    end
  end

  def cache_key(obj, options)
    key_components = [cache_key_class_name]
    key_components << (obj.try(:is_root_resource) ? 'r' : 'l')
    key_components << obj
    key_components << options.select{|k,v| Array(options['_keys']).include?(k.to_s)}

    ActiveSupport::Cache.expand_cache_key(key_components)
  end

  def cache
    Rails.cache
  end

  def cache_key_class_name
    self.class.name.underscore.gsub(/_representer$/, "")
  end

  def cache_options
    {compress: true, race_condition_ttl: 10, expires_in: 1.hour}
  end
end
