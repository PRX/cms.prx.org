require 'test_helper'

describe ApiAuthenticated do

  class ApiAuthenticatedTestController < ActionController::Base
    include ApiAuthenticated

    def current_user
      nil
    end

    def user_not_authorized
      raise 'user_not_authorized'
    end

    def prx_auth_token; end
  end

  let(:controller) { ApiAuthenticatedTestController.new }

  it 'does not cache index/show actions' do
    controller.cache_show?.must_equal false
    controller.cache_index?.must_equal false
  end

  it 'requires a logged in user' do
    controller.stub(:current_user, true) do
      controller.authenticate_user!
      controller.current_user.must_equal true
    end
  end

  it 'calls user_not_authorized if there is no user' do
    err = assert_raises { controller.authenticate_user! }
    err.message.must_match /user_not_authorized/
  end

  it 'builds an authorization from token' do
    controller.stub(:current_user, true) do
      controller.stub(:prx_auth_token, StubToken.new(123, 'admin', nil)) do
        controller.authorization.wont_be_nil
      end
    end
  end

end
