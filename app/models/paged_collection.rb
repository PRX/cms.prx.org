# encoding: utf-8

require 'forwardable'

class PagedCollection
  extend Forwardable

  attr_accessor :items, :request, :options

  def_delegators :items, :count, :total_count, :prev_page, :next_page, :total_pages, :first_page?, :last_page?
  alias_method :total, :total_count

  def_delegators :request, :params

  def initialize(items, request, options={})
    self.items   = items
    self.request = request
    self.options = options
  end

  def item_class
    options[:item_class] || self.items.first.class
  end

  def item_decorator
    options[:item_decorator] || "Api::#{item_class.name}Representer".constantize
  end

  def url_helper
    options[:url_helper] || "api_#{item_class.name.underscore.pluralize}_path"
  end

end
