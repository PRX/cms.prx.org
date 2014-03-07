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

  def to_json(*args)
    Rails.logger.debug "\nAK - #{self.class.name} to_json #{args.inspect}\n"
    super
  end

  def create_representation_with(*args)
    Rails.logger.debug "\nAK - #{self.class.name} create_representation_with #{args.inspect}\n"
    super
  end

  # def create_representation_with(*args)
  #   SerializedJson.new('{ "_links": { "enclosure": { "href": "/pub/1b8544e498bebd7298fbf754cfc78325/0/web/user_image/6840/original/67joshualightshow50.jpg", "type": "image/pjpeg" }, "self": { "href": "/api/v1/user_images/6840", "profile": "http://meta.prx.org/model/image/user" } }, "filename": "67joshualightshow50.jpg", "id": 6840, "size": 33608 }')
  # end

  # def to_hash(*args)
  #   Rails.logger.debug "\n#{self.class.name} to_hash #{args.inspect}\n"
  #   super
  # end

end
