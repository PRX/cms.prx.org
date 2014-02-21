# encoding: utf-8

class Api::PagedCollectionRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL

  property :count
  property :total

  link :self do
    helper(params)
  end

  link :prev do
    helper(params.merge(page: represented.prev_page)) unless represented.first_page?
  end

  link :next do
    helper(params.merge(page: represented.next_page)) unless represented.last_page?
  end

  link :first do
    helper(params.merge(page: nil))
  end

  link :last do
    helper(params.merge(page: represented.total_pages))
  end

  collection :items, embedded: true, decorator: lambda{|*| item_decorator }, class: lambda{|*| item_class }

  def params
    represented.params
  end

  def helper(options={})
    url_helper ? self.send(url_helper, options) : url_for(options.merge(only_path: true))
  end

  def url_helper
    represented.try(:url_helper) 
  end

end
