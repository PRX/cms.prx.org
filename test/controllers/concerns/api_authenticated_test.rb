# encoding: utf-8

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
  end

  let (:controller) { ApiAuthenticatedTestController.new }

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
    assert_match /user_not_authorized/, err.message
  end

end
