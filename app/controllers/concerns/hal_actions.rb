# encoding: utf-8

require 'active_support/concern'

# expects underlying model to have filename, class, and id attributes
module HalActions
  extend ActiveSupport::Concern
  include Actions
  include Cache
  include Resources

  module ClassMethods
    include Actions::ClassMethods
    include Cache::ClassMethods
    include Resources::ClassMethods
  end
end
