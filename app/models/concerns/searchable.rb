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
    def reindex
      __elasticsearch__.index_document
      refresh_index
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
      stager = index_stager
      indexer(stager).run
      stager.alias_stage_to_tmp_index && stager.promote
      __elasticsearch__.refresh_index!
    end

    private

    def self.index_stager
      Elasticsearch::Rails::HA::IndexStager.new(self.to_s)
    end

    def self.indexer(stager)
      Elasticsearch::Rails::HA::ParallelIndexer.new(
        klass: self.to_s,
        idx_name: stager.tmp_index_name,
        nprocs: ENV.fetch('NPROCS', 1),
        batch_size: ENV.fetch('BATCH', 100),
        force: true,
        verbose: ENV.fetch('ES_DEBUG', false)
      )
    end
  end
end
