require 'test_helper'

describe Api::UserImagesController do

  let(:user_image) { create(:user_image) }

  it 'should show' do
    get(:show, { api_version: 'v1', format: 'json', id: user_image.id } )
    assert_response :success
  end

  it 'should list' do
    user_image.id.wont_be_nil
    get(:index, { api_version: 'v1', format: 'json' } )
    assert_response :success
  end

  it 'should update if user has permission' do
    @controller.stub(:current_user, user_image.user) do
      get(:update, { api_version: 'v1', format: 'json', id: user_image.id })
    end

    assert_response :success
  end

  it 'should not update if user does not have permission' do
    @controller.stub(:current_user, create(:user)) do
      get(:update, { api_version: 'v1', format: 'json', id: user_image.id })
    end

    assert_response :unauthorized
  end

end
