# encoding: utf-8

class SearchIndexerJob < ApplicationJob
  queue_as :cms_search_indexer

  rescue_from ActiveRecord::RecordNotFound do |e|
    # ignore: always some chance this record was deleted
  end

  def perform(model)
    model.reindex
  end
end
