# encoding: utf-8

require 'active_support/concern'

# expects underlying model to have filename, class, and id attributes
module HalActions
  extend ActiveSupport::Concern
  include Actions
  include Cache
  include Resources

  included do
    rescue_from Errors::UnsupportedMediaType do |e|
      respond_with e, status: e.status, represent_with: Errors::Representer
    end
  end

  module ClassMethods
    include Actions::ClassMethods
    include Cache::ClassMethods
    include Resources::ClassMethods
  end
end
