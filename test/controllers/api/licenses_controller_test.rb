require 'test_helper'

describe Api::LicensesController do
  let(:user) { create(:user) }
  let(:story) { create(:story, account: user.individual_account) }
  let(:license) { create(:license, story: story) }

  it 'should show' do
    get(:show, { api_version: 'v1', format: 'json', id: license.id } )
    assert_response :success
  end

  it 'should list' do
    license.id.wont_be_nil
    get(:index, { api_version: 'v1', format: 'json' } )
    assert_response :success
  end
end
