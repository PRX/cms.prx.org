# encoding: utf-8

require 'active_support/concern'

# expects underlying model to have filename, class, and id attributes
module Caches

  extend ActiveSupport::Concern

  # Wrapper for string that is already json
  class SerializedJson
    def initialize(s); @s = s; end
    def to_json(*args); @s; end
    def to_s; @s; end

    # ActiveSupport adds as_json to Object
    # Oj will try to call this before to_json
    # by undefining, lets Oj use to_json
    undef_method :as_json
  end

  def to_json(options={})
    options[:_roar_format] = :json
    # Rails.logger.debug "\n\nAK - #{self.class.name} to_json #{options.inspect}\n\n"
    super(options)
  end

  def create_representation_with(doc, options, format)

    key = representer_cache_key(represented, options)

    Rails.logger.debug "\n\nAK - cache key: #{key} for #{self.class.name} : #{options.inspect}\n\n"


    # Rails.logger.debug "\n\nAK - #{self.class.name} create_representation_with #{options.inspect}\n\n"
    super
  end

  def representer_cache_key(obj, options)
    cache_options = options.select{|k,v| k.to_s.starts_with?('_roar_') || representer_cache_key_options.include?(k.to_s)}

    key_components = []
    key_components << Rails.application.class.parent_name
    key_components << self.class.name.underscore
    key_components << obj
    key_components << ActiveSupport::Cache.expand_cache_key(cache_options)
    ActiveSupport::Cache.expand_cache_key(key_components)
  end

  def representer_cache_key_options
    ['page']
  end

  # def create_representation_with(*args)
  #   SerializedJson.new('{ "_links": { "enclosure": { "href": "/pub/1b8544e498bebd7298fbf754cfc78325/0/web/user_image/6840/original/67joshualightshow50.jpg", "type": "image/pjpeg" }, "self": { "href": "/api/v1/user_images/6840", "profile": "http://meta.prx.org/model/image/user" } }, "filename": "67joshualightshow50.jpg", "id": 6840, "size": 33608 }')
  # end

  # def to_hash(*args)
  #   Rails.logger.debug "\n#{self.class.name} to_hash #{args.inspect}\n"
  #   super
  # end

end
