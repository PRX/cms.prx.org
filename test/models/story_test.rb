require "test_helper"

describe Story do
  it "has a table defined" do
    Story.table_name.must_equal 'pieces'
  end
end
