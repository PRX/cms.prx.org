# encoding: utf-8

require 'active_support/concern'

module AbstractResource
  extend ActiveSupport::Concern

  def show
    res = show_resource
    resource = res = res.becomes(res.type.safe_constantize) if res.type
    respond_with root_resource(res), abstract_options(:show, res)
  end

  def create
    create_resource.tap do |res|
      consume! res, create_options
      res = res.becomes(res.type.safe_constantize) if res.type
      hal_authorize res
      res.save!
      after_create_resource(res)
      respond_with root_resource(res), abstract_create_options(res)
    end
  end

  def abstract_create_options(res)
    abstract_options(:create, res).tap do |options|
      options[:location] = ''
    end
  end

  def abstract_options(action, res)
    valid_params_for_action(action).tap do |options|
      options[:_keys] = options.keys
      dec = decorator_for_model(res)
      options[:represent_with] = dec if dec
    end
  end

  def decorator_for_model(model)
    decorator_class(model.class.model_name.name) ||
      decorator_class(model.class.base_class.model_name.name)
  end

  def decorator_class(name)
    class_name = "Api::#{name}Representer"
    class_name.safe_constantize
  end

  def after_create_resource(_resource)
  end
end
