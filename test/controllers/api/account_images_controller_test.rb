require 'test_helper'

describe Api::AccountImagesController do

  let(:account_image) { FactoryGirl.create(:account_image) }

  it 'should show' do
    get(:show, { api_version: 'v1', format: 'json', id: account_image.id } )
    assert_response :success
  end

  it 'should list' do
    get(:index, { api_version: 'v1', format: 'json' } )
    assert_response :success
  end

end
