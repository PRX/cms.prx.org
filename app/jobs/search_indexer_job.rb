# encoding: utf-8

class SearchIndexerJob < ApplicationJob
  queue_as ENV['SQS_SEARCH_INDEXER_QUEUE_NAME']

  rescue_from ActiveRecord::RecordNotFound do |e|
    # ignore: always some chance this record was deleted
  end

  def perform(model)
    model.reindex
  end
end
