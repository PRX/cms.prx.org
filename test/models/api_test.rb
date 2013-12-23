require "test_helper"

describe Api do

  it "create an api with a version" do
    api = Api.version('1.0')
    api.version.must_equal '1.0'
  end

end
