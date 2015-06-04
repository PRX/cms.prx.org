# encoding: utf-8

require 'active_support/concern'
require 'announce_actions/announce_filter'

# expects underlying model to have filename, class, and id attributes
module AnnounceActions

  extend ActiveSupport::Concern

  module ClassMethods

    attr_accessor :announced_actions

    def announce_actions(*args)
      self.announced_actions ||= []

      options = args.extract_options!
      callback_options = options.slice(:only, :except, :if, :unless)

      actions = args.map(&:to_s).uniq
      actions = [:create, :update, :destroy] if actions.empty?

      actions.each do |action|
        next if announced_actions.include?(action)

        # remember this action already announcing, prevent dupes
        self.announced_actions << action

        # when it is a destroy action, default action name to 'delete'
        filter_options = options.slice(:action, :decorator)
        filter_options[:action] ||= 'delete' if action.to_s == 'destroy'
        announce_filter = AnnounceActions::AnnounceFilter.new(action, filter_options)

        # default callback options for only this action, and only on success
        callback_options.reverse_merge!(only: [action], if: ->() { response.successful? } )
        after_action announce_filter, callback_options
      end
    end
  end
end
