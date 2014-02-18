# encoding: utf-8

require 'forwardable'

class PagedCollection
  extend Forwardable

  attr_accessor :items, :request

  def_delegators :request, :params

  def_delegators :items, :count, :total_count, :prev_page, :next_page, :total_pages, :first_page?, :last_page?

  alias_method :total, :total_count

  def initialize(items, request)
    self.items = items
    self.request = request
  end

end
