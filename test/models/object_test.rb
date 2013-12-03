require "test_helper"

describe Object do
  before do
    @object = Object.new
  end

  it "must be an object" do
    @object.must_be_instance_of Object
  end
end
