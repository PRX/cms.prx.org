require 'test_helper'

describe Api::AuthorizationsController do

  let (:user) { create(:user) }
  let (:token) { StubToken.new(user.individual_account.id, 'cms:read-private', user.id) }

  it 'returns unauthorized with invalid token' do
    @controller.stub(:prx_auth_token, OpenStruct.new) do
      get(:show, api_version: 'v1')
      assert_response :unauthorized
    end
  end

  it 'returns unauthorized with no token' do
    get(:show, api_version: 'v1')
    assert_response :unauthorized
  end

  it 'is successful with a valid token' do
    @controller.stub(:prx_auth_token, token) do
      get(:show, api_version: 'v1')
      assert_response :success
    end
  end
end
