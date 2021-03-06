# encoding: utf-8

require 'active_support/concern'

module ChildResource
  extend ActiveSupport::Concern

  included do
    class_eval do
      class_attribute :child_resource_options
    end
  end

  def child_resource?
    !self.class.child_resource_options.blank?
  end

  def show_resource
    child_resource? ? child_resource : super
  end

  def update_resource
    child_resource? ? child_resource : super
  end

  def delete_resource
    child_resource? ? child_resource : super
  end

  def child_resource
    unless res = parent_resource.send(child_resource_name)
      raise HalApi::Errors::NotFound.new
    end
    res
  end

  def parent_resource
    parent_class = parent_resource_name.classify.safe_constantize
    parent_key = self.class.child_resource_options[:parent_key] || "#{parent_resource_name}_id"
    unless params[parent_key] && res = parent_class.find_by_id(params[parent_key])
      raise HalApi::Errors::NotFound.new
    end
    res
  end

  def create
    child_resource? ? create_child_resource : super
  end

  def create_child_resource
    create_resource.tap do |res|
      original = child_resource
      opts = create_options
      consume! res, opts
      hal_authorize res
      parent_resource.public_send("#{child_resource_name}=", res)
      try(:after_original_destroyed, original) if original && original.destroyed?
      try(:after_create_resource, res)
      respond_with root_resource(res), create_options
    end
  end

  def parent_resource_name
    self.class.child_resource_options[:parent]
  end

  def child_resource_name
    self.class.child_resource_options[:child]
  end

  module ClassMethods
    def child_resource(options)
      self.child_resource_options = options.with_indifferent_access
    end
  end
end
