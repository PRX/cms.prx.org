require 'test_helper'
require 'paged_collection' if !defined?(PagedCollection)
require 'test_models'

describe Api::PagedCollectionRepresenter do

  let(:items)            { (0..25).collect{|t| TestObject.new("test #{t}") } }
  let(:paged_items)      { Kaminari.paginate_array(items).page(1).per(10) }
  let(:paged_collection) { PagedCollection.new(paged_items, OpenStruct.new(params: {})) }
  let(:representer)      { Api::TestsRepresenter.new(paged_collection) }
  let(:json)             { JSON.parse(representer.to_json) }

  it 'creates a paged collection representer' do
    representer.wont_be_nil
  end

  it 'paged collection contains tests _links' do
    json['_embedded']['tests'].wont_be_nil
    json['_embedded']['tests'].size.must_equal 10
  end

end
