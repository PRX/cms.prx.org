require 'elasticsearch/model'

module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    after_commit on: [:create] do
      if Rails.env.test?
        #reindex # call manually in tests if needed, for performance reasons
      else
        # TODO put on async queue for indexing
      end
    end

    after_commit on: [:update] do
      if Rails.env.test?
        #reindex # call manually in tests if needed, for performance reasons
      else
        # TODO put on async queue for indexing
      end
    end

    after_commit on: [:destroy] do
      if Rails.env.test?
        #remove_from_index # call manually in tests if needed, for performance reasons
      else
        # TODO put on async queue to remove_from_index
      end
    end

    def reindex
      __elasticsearch__.index_document
      refresh_index
      self
    end

    def remove_from_index
      __elasticsearch__.destroy_document
      refresh_index
    end

    def refresh_index
      self.class.__elasticsearch__.refresh_index!
    end

    def self.rebuild_index
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