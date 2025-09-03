require 'test_helper'

describe Api::AddressesController do

  let(:account) { create(:group_account) }

  around { |test| @controller.stub(:current_user, true) { test.call } }

  it 'should show' do
    get :show, api_request_opts(account_id: account.id, id: account.address.id)
    assert_response :success
  end
end
