# encoding: utf-8

require 'active_support/concern'

module ChildResource
  extend ActiveSupport::Concern

  included do
    class_eval do
      class_attribute :child_resource_options
      include Announce::Publisher
    end
  end

  def create_resource
    is_child_resource? ? create_child_resource : super
  end

  def create_child_resource
    original = child_resource

    create_resource.tap do |res|
      consume! res, create_options
      hal_authorize res
      parent_resource.public_send("#{child_resource_name}=", res)
      respond_with root_resource(res), create_options
    end

    if original.destroyed?
      announce(child_resource_name, 'destroy', decorator_class.new(original).to_json)
    end
  end

  def show_resource
    is_child_resource? ? child_resource : super
  end

  def update_resource
    is_child_resource? ? child_resource : super
  end

  def delete_resource
    is_child_resource? ? child_resource : super
  end

  def parent_resource
    parent_class = parent_resource_name.classify.safe_constantize
    parent_key = self.class.child_resource_options[:parent_key] || "#{parent_resource_name}_id"
    @parent_resource ||= parent_class.find(params[parent_key]) if params[parent_key]
  end

  def child_resource
    @child_resource ||= parent_resource.try(child_resource_name)
  end

  def parent_resource_name
    self.class.child_resource_options[:parent]
  end

  def child_resource_name
    self.class.child_resource_options[:child]
  end

  def decorator_class
    if self.class.child_resource_options[:decorator]
      return self.class.child_resource_options[:decorator]
    else
      resource_class = controller.controller_name.singularize.camelize
      "Api::Min::#{resource_class}Representer".safe_constantize ||
        "Api::#{resource_class}Representer".safe_constantize
    end
  end

  module ClassMethods
    def child_resource(options)
      self.child_resource_options = options.with_indifferent_access
    end
  end

  def is_child_resource?
    !self.class.child_resource_options.blank?
  end
end
