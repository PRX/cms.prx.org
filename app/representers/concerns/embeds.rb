# encoding: utf-8

require 'active_support/concern'

# monkey patch Representable 1.8.5 (a debateable idea, got it from roar)
# so that an embedded attribute is not writeable
# https://github.com/apotonick/representable/blob/v1.8.5/lib/representable/readable_writeable.rb#L19
Representable::Definition.class_eval do
  # Checks and returns if the property is writeable
  def writeable?
    return !self[:embedded] if self.has_key?(:embedded)
    return self[:writeable] if self.has_key?(:writeable)
    true
  end
end

# expects underlying model to have filename, class, and id attributes
module Embeds
  extend ActiveSupport::Concern

  included do
    Representable::Mapper.send(:include, Embeds::Resources) if !Representable::Mapper.include?(Embeds::Resources)
  end

  module Resources

    def skip_property?(binding, options)
      super(binding, options) || suppress_embed?(binding, options)
    end

    # embed if zoomed
    def suppress_embed?(binding, options)
      name     = (binding[:as] || binding.name).to_s
      embedded = !!binding[:embedded]

      # not embedded, return false - nothing to suppress
      return false if !embedded

      # prevent embed deserialize in Representable 2.x
      # https://github.com/apotonick/representable/blob/v2.0.0/lib/representable/mapper.rb#L34
      return true if options[:action] && options[:action] == :deserialize

      # check if it should be zoomed, suppress if not
      return !embed_zoomed?(name, binding[:zoom], options[:zoom])
    end

    def embed_zoomed?(name, zoom_def=nil, zoom_param=nil)
      # if the embed in the representer definition has `zoom: :always` defined
      # always embed it, even if it is in another embed
      # (this is really meant for collections where embedded items must be included)
      return true if zoom_def == :always

      # passing nil explicitly overwrites defaults in signature,
      # so we default to nil and fix in the method body
      zoom_def = true if zoom_def.nil?

      # if there is no zoom specified in the request params (options)
      # then embed based on the zoom option in the representer definition

      # if there is a zoom specified in the request params (options)
      # then do not zoom when this name is not in the request
      zoom_param.nil? ? zoom_def : zoom_param.include?(name)
    end

  end

  # Possible values for zoom option in the embed representer definition
  # * false - will be zoomed only if in the root doc and in the zoom param
  # * true - zoomed in root doc if no zoom_param, or if included in zoom_param
  # * always - zoomed no matter what is in zoom param, and even if in embed
  module ClassMethods

    def embed(name, options={})
      options[:embedded] = true

      if options[:paged]
        opts = {no_curies: true, item_class: options.delete(:item_class), url: options.delete(:url), item_decorator: options.delete(:item_decorator)}
        options[:getter] ||= ->(*){ PagedCollection.new(self.send(name).page(1), nil, opts.merge({parent: self})) }
        options[:decorator] = Api::PagedCollectionRepresenter
      end

      property(name, options)
    end

    def embeds(name, options={})
      options[:embedded] = true
      collection(name, options)
    end

  end

end
