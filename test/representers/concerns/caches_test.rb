# encoding: utf-8

require 'test_helper'
require 'test_models'

describe Caches do

  let(:helper) { class TestCaches; include Caches; end.new }
  let(:object) { TestObject.new("test", true) }
  let(:representer) { Api::TestObjectRepresenter.new(object) }

  it 'creates a cache key for a model' do
    expect = "api/test_object/r/test/true/zoom/foo/bar/page/1"
    key = representer.cache_key(object, { 'zoom' => ['foo', 'bar'], 'to_' => :json, 'page' => 1, '_keys' => ['zoom', 'page'] })
    key.must_equal expect
  end

  it 'gets a cache name from the class' do
    representer.cache_key_class_name.must_equal 'api/test_object'
  end

  it 'handles json strings for caching' do
    test_string = {"key" => "value"}.to_json
    test_string.to_json.must_equal "\"{\\\"key\\\":\\\"value\\\"}\""
    sj = Caches::SerializedJson.new(test_string)
    sj.to_json.must_equal test_string
  end

  it "adds a hint as to final format for cache optimizations" do
    options = {}
    helper.to_json(options) rescue nil
    options[:to_].must_equal :json
  end

  it 'caches regular representation when not hinted to be json' do
    response = representer.create_representation_with({}, {}, Representable::Hash::PropertyBinding)
    response.must_be_instance_of(Hash)

    response = representer.create_representation_with({}, {to_: :json}, Representable::Hash::PropertyBinding)
    response.must_be_instance_of(Caches::SerializedJson)
  end

end
