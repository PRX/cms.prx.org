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
      subject = (options[:subject] || controller.controller_name).to_s.singularize
      announce(subject, resource_action, decorated_resource(controller))
    rescue Aws::SNS::Errors::NotFound => e
      Rails.logger.error("Non-existent SNS topic: #{Rails.env.downcase}_announce_#{subject}_#{action}")
      raise e
    end

    def resource_action
      (options[:action] || action).to_s
    end

    def decorated_resource(controller)
      decorator = decorator_class(controller)
      raise "No decorator specified: #{controller.inspect}" unless decorator
      res = announce_resource(action, controller)
      decorator.new(res).to_json
    end

    def announce_resource(action, controller)
      pre = "#{action}_" if controller.respond_to?("#{action}_resource", true)
      controller.send("#{pre}resource")
    end

    def decorator_class(controller)
      return options[:decorator] if options[:decorator]
      resource_class = controller.controller_name.singularize.camelize
      "Api::Msg::#{resource_class}Representer".safe_constantize ||
      "Api::Min::#{resource_class}Representer".safe_constantize ||
        "Api::#{resource_class}Representer".safe_constantize
    end
  end
end
