# encoding: utf-8

class SearchDeindexerJob < ApplicationJob
  queue_as :cms_search_indexer

  if ENV['SEARCH_INDEXER_QUEUE_NAME']
    queue_as ENV['SEARCH_INDEXER_QUEUE_NAME']
    self.queue_name_prefix = nil
  end

  def perform(class_name, id)
    klass = class_name.constantize
    klass.new(id: id).remove_from_index
  end
end
