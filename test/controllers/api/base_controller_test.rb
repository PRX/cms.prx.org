require 'test_helper'

describe Api::BaseController do

  it 'should show entrypoint' do
    get(:entrypoint, { api_version: 'v1', format: 'json' } )
    assert_response :success
  end

end
