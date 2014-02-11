require "test_helper"
require 'paged_collection'

TestObject = Struct.new(:title)

class Api::TestRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL

  property :title

  def api_tests_path(represented)
    "/api/tests/#{represented.title}"
  end

  link :self do
    api_tests_path(represented)
  end
end

class Api::TestsRepresenter < Roar::Decorator
  include Api::PagedCollectionRepresenter

  def api_tests_path(represented)
    "/api/tests?page=#{represented[:page] || 1}"
  end

  collection :items, as: :tests, embedded: true, class: TestObject, decorator: Api::TestRepresenter
end

describe Api::PagedCollectionRepresenter do

  before {
    @items = (0..25).collect{|t| TestObject.new("test #{t}") }
    @paged_items = Kaminari.paginate_array(@items).page(1).per(10)
    @paged_collection = PagedCollection.new(@paged_items, OpenStruct.new(params: {}))
    @paged_collection_representer = Api::TestsRepresenter.new(@paged_collection)
  }

  it "create paged collection" do
    @paged_collection_representer.wont_be_nil
  end

  it "paged collection contains tests _links" do
    h = ActiveSupport::HashWithIndifferentAccess.new(@paged_collection_representer.to_hash)
    h['_embedded']['tests'].wont_be_nil
    h['_embedded']['tests'].size.must_equal 10
  end

end
