require 'test_helper'

describe Api::StoryImagesController do
  let(:user) { create(:user) }
  let(:story_image) { create(:story_image) }
  let(:story) { story_image.story }
  let(:account) { story.account }
  let(:token) { StubToken.new(account.id, ['member'], user.id) }

  before(:each) do
    class << @controller; attr_accessor :prx_auth_token; end
    @controller.prx_auth_token = token
    @request.env['CONTENT_TYPE'] = 'application/json'
    clear_messages
  end

  it 'should show' do
    get(:show, api_request_opts(story_id: story.id, id: story_image.id))
    assert_response :success
  end

  it 'should list' do
    story_image.id.wont_be_nil
    get(:index, api_request_opts(story_id: story.id))
    assert_response :success
  end

  it 'should update' do
    image_hash = { credit: 'blah credit' }
    put(:update, image_hash.to_json, api_request_opts(story_id: story.id, id: story_image.id))
    assert_response :success
    last_message['subject'].to_s.must_equal 'image'
    last_message['action'].to_s.must_equal 'update'
    StoryImage.find(story_image.id).credit.must_equal('blah credit')
  end

  it 'triggers image transform! on update' do
    image_hash = { credit: 'credit' }
    mock_image = Minitest::Mock.new story_image
    
    mock_image.expect :transform!, true
    
    @controller.stub :authorize, true do
      @controller.stub :update_resource, mock_image do
        put(:update, image_hash.to_json, api_request_opts(story_id: account.id, id: story_image.id))
      end
    end

    mock_image.verify
  end

  it 'should create' do
    image_hash = {
      upload: 'http://thisisatest.com/guid1/image.gif',
      set_story_uri: api_story_url(story)
    }
    post(:create, image_hash.to_json, api_request_opts(story_id: story.id))
    assert_response :success
    last_message['subject'].to_s.must_equal 'image'
    last_message['action'].to_s.must_equal 'create'
  end

  it 'triggers image transform! on create' do
    image_hash = {
      upload: 'http://thisisatest.com/guid1/image.gif',
      set_series_uri: api_story_url(story)
    }
    
    story_image = StoryImage.where(story: story).build
    mock_image = Minitest::Mock.new(story_image)

    mock_image.expect :transform!, true

    @controller.stub :authorize, true do
      @controller.stub :create_resource, mock_image do
        post(:create, image_hash.to_json, api_request_opts(story_id: story.id))
      end
    end

    mock_image.verify
  end
end
