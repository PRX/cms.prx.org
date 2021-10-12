# encoding: utf-8

class SearchIndexerJob < ApplicationJob
  queue_as :cms_search_indexer

  if ENV['SEARCH_INDEXER_QUEUE_NAME']
    queue_as ENV['SEARCH_INDEXER_QUEUE_NAME']
    self.queue_name_prefix = nil
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    # ignore: always some chance this record was deleted
  end

  def perform(model)
    model.reindex
  end
end
