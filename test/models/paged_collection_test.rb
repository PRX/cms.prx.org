require "test_helper"

describe PagedCollection do

  it "create a paged collection" do
    paged_collection = PagedCollection.new(nil, nil)
    paged_collection.wont_be_nil
  end

end
