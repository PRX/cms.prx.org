require 'test_helper'

describe Api::StoryImagesController do
  let(:story_image) { create(:story_image) }

  it 'should show' do
    get(:show, api_request_opts(id: story_image.id))
    assert_response :success
  end

  it 'should list' do
    story_image.id.wont_be_nil
    get(:index, api_request_opts)
    assert_response :success
  end
end
