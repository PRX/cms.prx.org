require 'test_helper'

describe Api::AuthorizationsController do
  let (:user) { create(:user) }
  let (:token) { OpenStruct.new.tap do |t|
    t.user_id = user.id
  end }

  describe 'with valid authorization header' do
    it 'shows' do
      @controller.stub(:prx_auth_token, token) do
        get(:show, { api_version: 'v1', format: 'json' })
        response.status.must_equal 200
      end
    end

    it 'lists' do
      @controller.stub(:prx_auth_token, token) do
        get(:index, { api_version: 'v1', format: 'json' })
        response.status.must_equal 200
      end
    end
  end
end
