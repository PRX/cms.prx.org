require 'test_helper'

describe Api::LicensesController do

  let(:license) { FactoryGirl.create(:license) }

  it 'should show' do
    get(:show, { api_version: 'v1', format: 'json', id: license.id } )
    assert_response :success
  end

  it 'should list' do
    get(:index, { api_version: 'v1', format: 'json' } )
    assert_response :success
  end

end
