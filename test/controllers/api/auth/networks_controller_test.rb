require 'test_helper'
require 'json'

describe Api::Auth::NetworksController do
  let (:user) { create(:user) }
  let (:token) { OpenStruct.new.tap { |t| t.user_id = user.id } }
  let (:network) { create(:network, account: user.individual_account) }

  describe 'with a valid token' do

    around do |test|
      @controller.stub(:prx_auth_token, token) { test.call }
    end

    it 'should show' do
      get(:show, api_version: 'v1', format: 'json', id: network.id)
      assert_response :success
      resource = JSON.parse(@response.body)
      resource["id"].must_equal network.id
    end

    it 'should list' do
      network.id.wont_be_nil
      get(:index, api_version: 'v1', format: 'json')
      assert_response :success
      list = JSON.parse(@response.body)
      list["total"].must_equal 1
    end

  end

end
