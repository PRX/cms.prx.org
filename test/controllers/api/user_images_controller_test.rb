require 'test_helper'

describe Api::UserImagesController do

  let(:user_image) { FactoryGirl.create(:user_image) }

  it 'should show' do
    get(:show, { api_version: 'v1', format: 'json', id: user_image.id } )
    assert_response :success
  end

  it 'should list' do
    user_image.id.wont_be_nil
    get(:index, { api_version: 'v1', format: 'json' } )
    assert_response :success
  end

end
