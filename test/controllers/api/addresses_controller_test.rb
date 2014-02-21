require 'test_helper'

describe Api::AddressesController do

  let(:address) { FactoryGirl.create(:address) }

  it 'should show' do
    get(:show, { api_version: 'v1', format: 'json', id: address.id } )
    assert_response :success
  end

  it 'should list' do
    address.id.wont_be_nil
    get(:index, { api_version: 'v1', format: 'json' } )
    assert_response :success
  end

end
