require 'test_helper'

describe Api::StoryImagesController do

  let(:story_image) { FactoryGirl.create(:story_image) }

  it 'should show' do
    get(:show, { api_version: 'v1', format: 'json', id: story_image.id } )
    assert_response :success
  end

  it 'should list' do
    get(:index, { api_version: 'v1', format: 'json' } )
    assert_response :success
  end

end
