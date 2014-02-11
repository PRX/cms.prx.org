require "test_helper"

describe Api::ApiRepresenter do

  before(:each) {
    @api = Api.version('1.0')
    @api_representer = Api::ApiRepresenter.new(@api)
  }

  it "create api representer" do
    @api_representer.wont_be_nil
  end

  it "use api representer to create json" do
    @api_representer.to_json.must_equal '{"version":"1.0","_links":{"self":{"href":"/api/1.0"},"stories":[{"profile":"http://meta.prx.org/model/story","href":"/api/1.0/stories{?page}","templated":true},{"profile":"http://meta.prx.org/model/story","href":"/api/1.0/stories/{id}","templated":true}]}}'
  end

  it "create json for an api version" do
    h = @api_representer.to_hash
    h.keys.sort.must_equal ['_links', 'version']
    h['version'].must_equal '1.0'
  end

  it "return root doc with links for an api version" do
    h = @api_representer.to_hash
    h['_links']['self'][:href].must_equal '/api/1.0'
    h['_links']['stories'].size.must_equal 2
  end

end
