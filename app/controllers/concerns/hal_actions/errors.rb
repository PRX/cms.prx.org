module HalActions::Errors
  class UnsupportedMediaType < StandardError
    def initialize(type)
      @type = type
    end

    def message
      "Cannot consume unregistered media type '#{@type.inspect}'"
    end

    def status
      415
    end
  end

  module Representer
    include Roar::Representer::JSON::HAL

    property :status
    property :message
  end
end
