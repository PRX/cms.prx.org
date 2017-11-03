# encoding: utf-8

require 'announce'

# expects underlying model to have filename, class, and id attributes
module AnnounceActions

  class AnnounceFilter
    include Announce::Publisher

    attr_accessor :action, :options

    def initialize(action, options = {})
      @action = action
      @options = options
    end

    def after(controller)
      model = announce_resource(action, controller)
      subject = announce_subject(model)
      message = announce_message(model)
      if model.respond_to?(:with_lock)
        model.with_lock do
          announce(subject, announce_action, message)
        end
      else
        announce(subject, announce_action, message)
      end
    rescue Aws::SNS::Errors::NotFound => e
      Rails.logger.error("Non-existent SNS topic: #{Rails.env.downcase}_announce_#{subject}_#{action}")
      raise e
    end

    def announce_subject(model)
      (options[:subject] || model.class.base_class.model_name.singular).to_s
    end

    def announce_action
      (options[:action] || action).to_s
    end

    def announce_resource(action, controller)
      if options[:resource]
        controller.send(options[:resource])
      else
        pre = "#{action}_" if controller.respond_to?("#{action}_resource", true)
        controller.send("#{pre}resource")
      end
    end

    def announce_message(model)
      decorator = announce_decorator(model)
      decorator.new(model).to_json
    end

    def announce_decorator(resource)
      result = if options[:decorator]
        options[:decorator]
      else
        decorator_for_model(resource)
      end

      raise "No decorator specified: #{resource.inspect}" unless result
      result
    end

    def decorator_for_model(model)
      decorator_class(model.class.model_name.name) ||
      decorator_class(model.class.base_class.model_name.name)
    end

    def decorator_class(name)
      "Api::Msg::#{name}Representer".safe_constantize ||
        "Api::#{name}Representer".safe_constantize ||
        "Api::Min::#{name}Representer".safe_constantize
    end
  end
end
