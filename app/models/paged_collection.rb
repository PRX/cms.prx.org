# encoding: utf-8

require 'forwardable'

class PagedCollection
  extend ActiveModel::Naming
  extend Forwardable

  attr_accessor :items, :request, :options

  def_delegators :items, :count, :total_count, :prev_page, :next_page, :total_pages, :first_page?, :last_page?
  alias_method :total, :total_count

  def_delegators :request, :params

  def initialize(items, request=nil, options=nil)
    self.items   = items
    self.request = request || request_stub
    self.options = options || {}
    self.options[:is_root_resource] = true unless (self.options[:is_root_resource] == false)
  end

  def request_stub
    OpenStruct.new(params: {})
  end

  def is_root_resource
    !!self.options[:is_root_resource]
  end

  def show_curies
    is_root_resource && !options[:no_curies]
  end

  def item_class
    options[:item_class] || self.items.first.try(:item_class) || self.items.first.class
  end

  def item_decorator
    options[:item_decorator] || "Api::#{item_class.name}Representer".constantize
  end

  # url to use for the self:href, can be a string or proc
  def url
    options[:url]
  end

  # If this is an embedded collection, the parent will be set here for use in urls
  def parent
    options[:parent]
  end

end
