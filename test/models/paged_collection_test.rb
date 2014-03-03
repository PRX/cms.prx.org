require 'test_helper'
require 'paged_collection'
require 'test_models'

describe PagedCollection do

  let(:items)            { (0..25).collect{|t| TestObject.new("test #{t}") } }
  let(:paged_items)      { Kaminari.paginate_array(items).page(1).per(10) }
  let(:paged_collection) { PagedCollection.new(paged_items, OpenStruct.new(params: {})) }

  it 'creates a paged collection' do
    paged_collection.wont_be_nil
    paged_collection.items.wont_be_nil
    paged_collection.request.wont_be_nil
  end

  it 'has delegated methods' do
    paged_collection.request.params.must_equal Hash.new
    paged_collection.params.must_equal Hash.new

    paged_collection.items.count.must_equal 10
    paged_collection.count.must_equal 10
    paged_collection.items.total_count.must_equal 26
    paged_collection.total.must_equal 26
  end

  it 'can be a root resource from options' do
    paged_collection.is_root_resource.must_equal false
    paged_collection.options[:is_root_resource] = true
    paged_collection.is_root_resource.must_equal true    
  end

  it 'has an item_class' do
    paged_collection.item_class.must_equal(TestObject)
  end

  it 'has an item_decorator' do
    paged_collection.item_decorator.must_equal(Api::TestObjectRepresenter)
  end

end
