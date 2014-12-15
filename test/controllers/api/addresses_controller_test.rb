require 'test_helper'

describe Api::AddressesController do

  let(:account) { create(:group_account) }

  it 'should show' do
    get(:show, { api_version: 'v1', format: 'json', account_id: account.id, id: account.address.id } )
    assert_response :success
  end

end
