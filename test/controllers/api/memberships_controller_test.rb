require 'test_helper'

describe Api::MembershipsController do

  let(:membership) { FactoryGirl.create(:membership) }

  it 'should show for account' do
    get(:show, { api_version: 'v1', format: 'json', account_id: membership.account_id, id: membership.id } )
    assert_response :success
  end

  it 'should show for user' do
    get(:show, { api_version: 'v1', format: 'json', user_id: membership.user_id, id: membership.id } )
    assert_response :success
  end

  it 'should list' do
    membership.id.wont_be_nil
    get(:index, { api_version: 'v1', format: 'json', user_id: membership.user_id } )
    assert_response :success
  end

end
