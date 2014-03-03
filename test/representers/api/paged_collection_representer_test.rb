# encoding: utf-8

require 'test_helper'
require 'paged_collection' if !defined?(PagedCollection)
require 'test_models'

describe Api::PagedCollectionRepresenter do

  let(:items)            { (0..25).collect{|t| TestObject.new("test #{t}") } }
  let(:paged_items)      { Kaminari.paginate_array(items).page(1).per(10) }
  let(:request)          { OpenStruct.new(params: {"page"=>"1", "action"=>"index", "api_version"=>"v1", "controller"=>"api/test_objects", "format"=>"json"}) }
  let(:paged_collection) { PagedCollection.new(paged_items, request, is_root_resource: true) }
  let(:representer)      { Api::PagedCollectionRepresenter.new(paged_collection) }
  let(:json)             { JSON.parse(representer.to_json) }

  it 'creates a paged collection representer' do
    representer.wont_be_nil
  end

  it 'paged collection contains tests _links' do
    json['_embedded']['prx:items'].wont_be_nil
    json['_embedded']['prx:items'].size.must_equal 10
  end

end
