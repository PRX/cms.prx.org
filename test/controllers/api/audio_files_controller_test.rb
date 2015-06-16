require 'test_helper'

describe Api::AudioFilesController do
  let(:account) { create(:account) }
  let(:token) { StubToken.new(account.id, ['member']) }
  let(:story) { create(:story, account: account) }
  let(:audio_file) { create(:audio_file, story: story, account: account) }

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
      post :create, af_hash.to_json, api_request_opts(story_id: story.id)
      assert_response :success
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
end
