require 'test_helper'

describe Api::NetworksController do
  let(:user) { create(:user) }
  let(:network) { create(:network, account: user.individual_account) }

  it 'should show' do
    get(:show, { api_version: 'v1', format: 'json', id: network.id } )
    assert_response :success
  end

  it 'should list' do
    network.id.wont_be_nil
    get(:index, { api_version: 'v1', format: 'json' } )
    assert_response :success
  end
end
