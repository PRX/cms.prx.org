# encoding: utf-8

require 'active_support/concern'

# expects underlying model to have filename, class, and id attributes
module CurieHelper
  extend ActiveSupport::Concern

  included do
    class_attribute :default_curie, instance_writer: false
  end

  module ClassMethods

    LINK_RELATIONS = %w(about alternate appendix archives author bookmark canonical chapter collection contents copyright create-form curies current describedby describes disclosure duplicate edit edit-form edit-media enclosure first glossary help hosts hub icon index item last latest-version license lrdd memento monitor monitor-group next next-archive nofollow noreferrer original payment predecessor-version prefetch prev preview previous prev-archive privacy-policy profile related replies search section self service start stylesheet subsection successor-version tag terms-of-service timegate timemap type up version-history via working-copy working-copy-of)

    def use_curie(curie)
      self.default_curie = curie
    end

    def curies(curie, &block)
      use_curie(curie) unless default_curie
      link({rel: :curies, array: true}) do
        if represented.try(:is_root_resource)
          array = block.call
          name = array.first[:name]
          array 
        end
      end
    end

    def curify(rel, curie=default_curie)
      return rel if (curie.blank? || rel.to_s.match(/\w+:\w+/) || LINK_RELATIONS.include?(rel.to_s))
      "#{curie}:#{rel}".to_sym
    end

    def link(options, &block)
      options = {:rel => options} unless options.is_a?(Hash)
      options[:rel] = curify(options[:rel])
      super(options, &block)
    end

    def property(name, options={})
      options[:as] = curify(options[:as] || name) if options[:embedded]
      super(name, options)
    end

    def collection(name, options={})
      options[:as] = curify(options[:as] || name) if options[:embedded]
      super(name, options)
    end

  end

end
