# encoding: utf-8

require 'active_support/concern'

# Link relation names seem to have a standard of being dasherized, as they are URIs
# property names, on the other hand should, should be camelcase, lower first
module FormatKeys
  extend ActiveSupport::Concern

  module ClassMethods

    def link(options, &block)
      options = {:rel => options} unless options.is_a?(Hash)
      options[:rel] = options[:rel].to_s.dasherize
      super(options, &block)
    end

    def property(name, options={})
      n = (options[:as] || name).to_s
      options[:as] = options[:embedded] ? n.dasherize : n.camelize(:lower)
      super(name, options)
    end

    def collection(name, options={})
      n = (options[:as] || name).to_s
      options[:as] = options[:embedded] ? n.dasherize : n.camelize(:lower)
      super(name, options)
    end
  end
end
