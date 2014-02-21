require 'test_helper'

describe Api::MembershipsController do

  let(:membership) { FactoryGirl.create(:membership) }

  it 'should show' do
    get(:show, { api_version: 'v1', format: 'json', id: membership.id } )
    assert_response :success
  end

  it 'should list' do
    get(:index, { api_version: 'v1', format: 'json' } )
    assert_response :success
  end

end
