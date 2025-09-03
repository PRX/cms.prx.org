require 'test_helper'

describe Api::UsersController do
  let(:user) { create(:user) }

  around { |test| @controller.stub(:current_user, true) { test.call } }

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
