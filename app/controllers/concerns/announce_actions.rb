# encoding: utf-8

require 'active_support/concern'
require 'announce_actions/announce_filter'

# expects underlying model to have filename, class, and id attributes
module AnnounceActions
  extend ActiveSupport::Concern

  module ClassMethods
    attr_accessor :announced_actions

    def announce_actions(*args)
      self.announced_actions ||= Hash.new { |hash, action| hash[action] = [] }

      options = args.extract_options!

      actions = args.map(&:to_s).uniq
      actions = %i[create update destroy] if actions.empty?

      actions.each do |action|
        next if announced_actions[action].include?(options)

        add_announce_filter(action, options)

        # remember this action-options combo already announcing, prevent dupes
        self.announced_actions[action] << options
      end
    end

    def add_announce_filter(action, options)
      # when it is a destroy action, default action name to 'delete'
      announce_filter = new_announce_filter(action, options)

      # default callback options for only this action, and only on success
      default_options = { only: [action], if: -> { response.successful? } }
      callback_options = options.slice(:only, :except, :if, :unless)

      after_action announce_filter, default_options.merge(callback_options)
    end

    def new_announce_filter(action, options)
      filter_options = options.slice(:action, :decorator, :subject, :resource)
      filter_options[:action] ||= 'delete' if action.to_s == 'destroy'
      AnnounceActions::AnnounceFilter.new(action, filter_options)
    end
  end
end
