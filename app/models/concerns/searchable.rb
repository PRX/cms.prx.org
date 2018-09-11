require 'elasticsearch/model'

module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    after_commit on: [:create, :update] do
      if Rails.env.test?
        #reindex # call manually in tests if needed, for performance reasons
      else
        SearchIndexerJob.perform_later self
      end
    end

    after_commit on: [:destroy] do
      if Rails.env.test?
        #remove_from_index # call manually in tests if needed, for performance reasons
      else
        SearchDeindexerJob.perform_later self.class.name, id
      end
    end

    # shorthand methods
    def reindex(refresh = false)
      __elasticsearch__.index_document
      refresh_index if refresh
      self
    end

    def remove_from_index
      __elasticsearch__.delete_document
      refresh_index
    end

    def refresh_index
      self.class.__elasticsearch__.refresh_index!
    end

    # class method shorthand, useful for triggering via rake task or console or tests
    def self.rebuild_index(_opts = {})
      __elasticsearch__.create_index! unless __elasticsearch__.index_exists?

      indexer_scope = respond_to?(:for_indexer) ? :for_indexer : nil
      errs = import(refresh: true, return: 'errors', scope: indexer_scope)

      errs.each do |err|
        logger.error(err)
        NewRelic::Agent.notice_error(err)
      end
    end
  end
end
