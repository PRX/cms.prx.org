require 'test_helper'

describe Api::AudioFilesController do
  let(:user) { create(:user) }
  let(:story) { create(:story, account: user.approved_accounts.first) }
  let(:audio_file) { create(:audio_file, story: story) }

  describe '#create' do

    before { @controller.current_user = user }

    it 'can create an audio file for an account' do
      audio_file_hash = { size: 1024, duration: 30, upload: 'http://thisisatest.com/guid1/test.mp3', set_account_uri: api_account_url(story.account) }
      post :create, audio_file_hash.to_json, api_version: 'v1', format: 'json'
      assert_response :success
    end

    it 'can create an audio file for a story' do
      audio_file_hash = { upload: "http://thisisatest.com/guid1/test.mp3", size: 1024, duration: 30}
      post :create, audio_file_hash.to_json, api_version: 'v1', format: 'json', story_id: story.id
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
