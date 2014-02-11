require "test_helper"

describe Api::ApiRepresenter do

  before(:each) {
    @api = Api.version('1.0')
    @api_representer = Api::ApiRepresenter.new(@api)
    @json = JSON.parse(@api_representer.to_json)
  }

  it "create api representer" do
    @api_representer.wont_be_nil
  end

  it "use api representer to create json" do
    @json['version'].must_equal '1.0'
    @json.keys.sort.must_equal ['_links', 'version']
  end

  it "return root doc with links for an api version" do
    @json['_links']['self']['href'].must_equal '/api/1.0'
    @json['_links']['stories'].size.must_equal 2
  end

end
