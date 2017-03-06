require 'test_helper'
require 'json'

describe Api::NetworksController do
  let(:user) { create(:user) }
  let(:network) { create(:network, account: user.individual_account) }

  before { Network.delete_all }

  it 'should show' do
    get(:show, api_version: 'v1', format: 'json', id: network.id)
    resource = JSON.parse(@response.body)
    resource['id'].must_equal network.id
    assert_response :success
  end

  it 'should list' do
    network.id.wont_be_nil
    get(:index, api_version: 'v1', format: 'json')
    list = JSON.parse(@response.body)
    list['total'].must_equal 1
    assert_response :success
  end
end
