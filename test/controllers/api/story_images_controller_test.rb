require 'test_helper'

describe Api::StoryImagesController do
  let(:story_image) { create(:story_image) }
  let(:story) { story_image.story }
  let(:account) { story.account }
  let(:token) { StubToken.new(account.id, ['member']) }

  before(:each) do
    class << @controller; attr_accessor :prx_auth_token; end
    @controller.prx_auth_token = token
    @request.env['CONTENT_TYPE'] = 'application/json'
  end

  it 'should show' do
    get(:show, api_request_opts(id: story_image.id))
    assert_response :success
  end

  it 'should list' do
    story_image.id.wont_be_nil
    get(:index, api_request_opts)
    assert_response :success
  end

  it 'should update' do
    image_hash = { credit: 'blah credit' }
    put :update, image_hash.to_json, api_request_opts(story_id: story.id, id: story_image.id)
    assert_response :success
    StoryImage.find(story_image.id).credit.must_equal('blah credit')
  end

end
