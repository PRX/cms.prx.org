require 'test_helper'
require 'test_models'
require 'paged_collection'

describe PagedCollection do

  before {
    @items = (0..25).collect{|t| TestObject.new("test #{t}") }
    @paged_items = Kaminari.paginate_array(@items).page(1).per(10)
    @paged_collection = PagedCollection.new(@paged_items, OpenStruct.new(params: {}))
  }

  it 'creates a paged collection' do
    paged_collection = PagedCollection.new(@paged_items, OpenStruct.new(params: {}))
    paged_collection.wont_be_nil
    paged_collection.items.wont_be_nil
    paged_collection.request.wont_be_nil
  end

  it 'has delegated methods' do
    @paged_collection.request.params.must_equal Hash.new
    @paged_collection.params.must_equal Hash.new

    @paged_collection.items.count.must_equal 10
    @paged_collection.count.must_equal 10
    @paged_collection.items.total_count.must_equal 26
    @paged_collection.total.must_equal 26
  end

end
