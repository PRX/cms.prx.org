# encoding: utf-8

require 'active_support/concern'

# expects underlying model to have filename, class, and id attributes
module Caches
  extend ActiveSupport::Concern

  included do
    include Resources
    # TODO - check to make sure this is not included mutliple times.
    Representable::Mapper.send(:include, Caches::Resources)
  end

  module Resources

    def serialize(doc, options)
      # Rails.logger.debug("serialize:\n - doc: #{doc.inspect}\n - options: #{options.inspect}\n - self:#{self.inspect}\n\n")
      # Rails.logger.debug("serialize:\n - represented: #{represented.cache_key}\n - options: #{options.inspect}\n\n")
      super(doc, options)
    end

  end

end
