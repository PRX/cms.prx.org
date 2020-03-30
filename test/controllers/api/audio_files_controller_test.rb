require 'test_helper'

describe Api::AudioFilesController do
  let(:user) { create(:user) }
  let(:account) { create(:account) }
  let(:token) { StubToken.new(account.id, ['member'], user.id) }
  let(:story) { create(:story, account: account) }
  let(:story_with_version) { create(:story, account: account) }
  let(:audio_file) { create(:audio_file, story: story, account: account) }
  let(:audio_version) { audio_file.audio_version }

  before(:each) do
    class << @controller; attr_accessor :prx_auth_token; end
    @controller.prx_auth_token = token
  end

  describe '#create' do
    it 'can create an audio file for an account' do
      af_hash = {
        size: 1024,
        duration: 30,
        upload: 'http://thisisatest.com/guid1/test.mp3',
        set_account_uri: api_account_url(story.account)
      }
      @request.env['CONTENT_TYPE'] = 'application/json'
      post :create, af_hash.to_json, api_request_opts
      assert_response :success
    end

    it 'can create an audio file for a story' do
      af_hash = {
        upload: "http://thisisatest.com/guid1/test.mp3",
        size: 1024,
        duration: 30
      }
      @request.env['CONTENT_TYPE'] = 'application/json'
      post :create, af_hash.to_json, api_request_opts(story_id: story_with_version.id)
      assert_response :success
    end

    it 'triggers processing on create' do
      mock_file = MiniTest::Mock.new
      mock_file.expect(:process!, true)
      @controller.send(:after_create_resource, mock_file)

      mock_file.verify
    end

    it 'triggers processing on update' do
      mock_file = MiniTest::Mock.new
      mock_file.expect(:process!, true)
      @controller.send(:after_update_resource, mock_file)

      mock_file.verify
    end

    it 'can create an audio file for an audio version' do
      af_hash = {
        upload: 'http://thisisatest.com/guid1/test.mp3',
        size: 1024,
        duration: 30
      }
      @request.env['CONTENT_TYPE'] = 'application/json'
      post :create, af_hash.to_json, api_request_opts(audio_version_id: audio_version.id)
      assert_response :success
    end

    it 'can create an audio file for an account with the route' do
      af_hash = {
        size: 1024,
        duration: 212,
        upload: 'http://thisisatest.com/guid1/test.mp3'
      }
      @request.env['CONTENT_TYPE'] = 'application/json'
      post :create, af_hash.to_json, api_request_opts(account_id: story.account.id)
      assert_response :success

      AudioFile.find(JSON.parse(response.body)['id']).account_id.must_equal story.account.id
    end
  end

  it 'should show' do
    get :show, api_request_opts(id: audio_file.id)
    assert_response :success
  end

  it 'should list for version' do
    audio_file.id.wont_be_nil
    get :index, api_request_opts(audio_version_id: audio_file.audio_version_id)
    assert_response :success
  end

  it 'should list for story' do
    audio_file.id.wont_be_nil
    get :index, api_request_opts(story_id: story.id)
    assert_response :success
  end

  describe '#original' do
    let(:bad_token) { StubToken.new(account.id, ['member']) }
    let(:token) { StubToken.new(account.id, ['member', 'read-private']) }

    before(:each) do
      class << @controller; attr_accessor :prx_auth_token; end
      @controller.prx_auth_token = token
    end

    it 'should fail to get original when not authorized' do
      @controller.prx_auth_token = nil
      get :original, api_request_opts(id: audio_file.id)
      assert_response 401
    end

    it 'should fail to get original when token not authorized' do
      @controller.prx_auth_token = bad_token
      get :original, api_request_opts(id: audio_file.id)
      assert_response 401
    end

    it 'should redirect to download url' do
      @controller.prx_auth_token = token
      get :original, api_request_opts(id: audio_file.id)
      assert_response :redirect
    end
  end
end
