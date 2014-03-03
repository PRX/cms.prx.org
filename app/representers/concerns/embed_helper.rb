# encoding: utf-8

require 'active_support/concern'

# expects underlying model to have filename, class, and id attributes
module EmbedHelper
  extend ActiveSupport::Concern

  included do
    include Resources

    def representable_mapper(*) # TODO: make this easier to override.
      super.tap do |map|
        map.extend Roar::Representer::JSON::HAL::Resources
        map.extend Resources
      end
    end
  end

  module Resources

    # experimenting with detecting depth here
    # and if the proprty is marked root only, don't include
    # eventually, compare current depth to max depth option
    def skip_property?(binding, options)
      embedded = binding.options[:embedded]
      root_only = binding.options[:root_only]
      super(binding, options) #|| (embedded && root_only)
    end
  end

  module ClassMethods

    def embed(name, options={})
      options[:embedded] = true
      options[:root_only] = true
      # options[:if] ||= ->{ self.is_root_resource }
      property(name, options)
    end

    def embeds(name, options={})
      options[:embedded] = true
      options[:root_only] = true
      # options[:if] ||= ->{ self.is_root_resource }
      collection(name, options)
    end

  end

end
