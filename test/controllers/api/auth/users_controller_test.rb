require 'test_helper'

describe Api::Auth::UsersController do

  let (:user) { create(:user) }
  let (:token) { StubToken.new(nil, nil, user.id) }

  describe 'with a valid token' do
    around do |test|
      @request.env['CONTENT_TYPE'] = 'application/json'
      @controller.stub(:prx_auth_token, token) { test.call }
    end

    it 'should show' do
      user.id.wont_be_nil
      get :index, api_request_opts(id: user.id)
      assert_response :success
    end

    it 'should list' do
      user.id.wont_be_nil
      get :index, api_request_opts
      assert_response :success
    end
  end

  describe 'with no token' do
    it 'will not show you anything' do
      get(:show, api_version: 'v1', id: user.id)
      assert_response :unauthorized
    end

    it 'will not index you anything' do
      get(:index, api_version: 'v1')
      assert_response :unauthorized
    end
  end
end
