require 'test_helper'

describe Api::UsersController do
  let(:user) { create(:user) }
  let(:bad_user) { create(:user) }

  describe '#update' do
    it 'does not let a user update another user' do
      @controller.stub(:current_user, bad_user) do
        get(:update, api_version: 'v1',
                     format: 'json',
                     id: user.id)
      end

      assert_response :unauthorized
    end

    it 'lets a user update themself' do
      @controller.stub(:current_user, user) do
        get(:update,  api_version: 'v1',
                      format: 'json',
                      id: user.id)
      end

      assert_response :success
    end
  end
end
