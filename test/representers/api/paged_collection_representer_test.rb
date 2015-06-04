# encoding: utf-8

require 'test_helper'
require 'paged_collection' if !defined?(PagedCollection)
require 'test_models'

describe Api::PagedCollectionRepresenter do

  let(:items)            { (0..25).collect{|t| TestObject.new("test #{t}", true) } }
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

  it 'has a represented_url' do
    representer.represented.options[:url] = "api_stories_path"
    representer.represented_url.must_equal "api_stories_path"
  end

  it 'gets a route url helper method' do
    representer.represented.options[:url] = "api_stories_path"
    representer.href_url_helper({page: 1}).must_equal "/api/v1/stories?page=1"
  end

  it 'uses a lambda for a url method' do
    representer.represented.options[:url] = ->(options){ options.keys.sort.join('/') }
    representer.href_url_helper({foo: 1, bar: 2, camp: 3}).must_equal "bar/camp/foo"
  end

  it 'uses a lambda for a url method, references represented parent' do
    representer.represented.options[:parent] = "this is a test"
    representer.represented.options[:url] = ->(options){ represented.parent }
    representer.href_url_helper({foo: 1, bar: 2, camp: 3}).must_equal "this is a test"
  end

  describe 'test with routing' do

    before { define_routes }
    after { Rails.application.reload_routes! }

    it 'gets a route url helper method with parent' do
      representer.represented.options[:parent] = TestParent.new(1, true)
      representer.represented.options[:item_class] = TestObject
      representer.href_url_helper({page: 1}).must_equal "/api/test_parent/1/test_objects?page=1"
    end
  end
end
