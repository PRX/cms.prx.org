require 'test_helper'

describe Api::BaseController do

  it 'should show entrypoint' do
    get(:entrypoint, { api_version: 'v1', format: 'json' } )
    assert_response :success
  end

  it "should return missing for record not found" do
    raises_exception = ->(version) { raise(ActiveRecord::RecordNotFound.new(version)) }
    Api.stub :version, raises_exception do
      get(:entrypoint, { api_version: 'v1', format: 'json' } )
      assert_response :missing
    end
  end

  it "determines show action options for roar" do
    @controller.class.resource_representer = "rr"
    @controller.show_options.must_equal({zoom_param: nil, represent_with: "rr"})
  end

  it "can parse a zoom parameter" do
    @controller.params[:zoom] = "a,test"
    @controller.zoom_param.must_equal ['a', 'test']
  end

end
