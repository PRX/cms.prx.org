require "test_helper"

describe Api::ApiRepresenter do

  it "create json for an api with a version" do
    api = Api.version('1.0')
    api_representer = Api::ApiRepresenter.new(api)
    api_representer.wont_be_nil
    api_representer
  end

end
