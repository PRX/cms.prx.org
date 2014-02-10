require "test_helper"
require 'ostruct'

TestObject = Struct.new(:title)

class Api::TestRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL

  property :title

  link :self do
    "/test/#{represented.title}"
  end
end

class Api::TestsRepresenter < Roar::Decorator
  include Api::PagedCollectionRepresenter

  collection :items, as: :tests, embedded: true, class: TestObject, decorator: Api::TestRepresenter
end

describe Api::PagedCollectionRepresenter do

  it "create paged collection" do
    items = (0..25).collect{|t| TestObject.new(title: "test #{t}") }
    paged_items = Kaminari.paginate_array(items).page(1).per(10)
    paged_collection = PagedCollection.new(items, OpenStruct.new(params: {}))
    tests_representer = Api::TestsRepresenter.new(paged_collection)

    tests_representer.wont_be_nil
  end

end
