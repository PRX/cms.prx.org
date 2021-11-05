# encoding: utf-8

class SearchDeindexerJob < ApplicationJob
  queue_as :cms_search_indexer

  def perform(class_name, id)
    klass = class_name.constantize
    klass.new(id: id).remove_from_index
  end
end
