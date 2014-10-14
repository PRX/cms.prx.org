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

  describe '#update' do
    it 'should update if user has permission' do
      @controller.stub(:current_user, user) do
        get(:update, api_version: 'v1', format: 'json', id: license.id)
      end

      assert_response :success
    end

    it 'should not update if user does not have permission' do
      user2 = create(:user)
      @controller.stub(:current_user, user2) do
        get(:update, api_version: 'v1', format: 'json', id: license.id)
      end

      assert_response :unauthorized
    end
  end
end
