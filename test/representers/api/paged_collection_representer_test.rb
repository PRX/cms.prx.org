require 'test_helper'
require 'paged_collection' if !defined?(PagedCollection)
require 'test_models'

describe Api::PagedCollectionRepresenter do

  before {
    @items = (0..25).collect{|t| TestObject.new("test #{t}") }
    @paged_items = Kaminari.paginate_array(@items).page(1).per(10)
    @paged_collection = PagedCollection.new(@paged_items, OpenStruct.new(params: {}))
    @paged_collection_representer = Api::TestsRepresenter.new(@paged_collection)
    @json = JSON.parse(@paged_collection_representer.to_json)
  }

  it 'creates a paged collection representer' do
    @paged_collection_representer.wont_be_nil
  end

  it 'paged collection contains tests _links' do
    @json['_embedded']['tests'].wont_be_nil
    @json['_embedded']['tests'].size.must_equal 10
  end

end
