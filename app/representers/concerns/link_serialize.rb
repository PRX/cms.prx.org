# encoding: utf-8

require 'active_support/concern'

module LinkSerialize

  extend ActiveSupport::Concern

  module ClassMethods

    def link(options, &block)
      set_link_property(options)
      super(options, &block)
    end

    def set_link_property(options)
      if options.is_a?(Hash) && (options.delete(:writeable) || options[:reader])
        name   = options[:rel].to_s.split(':').last.split('/').last
        pname  = "set_#{name}_uri"
        reader = options.delete(:reader) || ->(doc, _args) do
          self.try("#{name}_id=", id_from_url(doc[pname])) if doc[pname]
        end

        property(pname, readable: false, reader: reader)
      end
    end

  end
end
