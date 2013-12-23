require "test_helper"

describe Story do
  before do
    @story = Story.new
  end

  it "has a table defined" do
    Story.table_name.must_equal 'pieces'
  end
end
