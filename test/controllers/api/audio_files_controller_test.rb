require 'test_helper'

describe Api::AudioFilesController do
  let(:user) { create(:user) }
  let(:story) { create(:story, account: user.individual_account) }
  let(:audio_file) { create(:audio_file, story: story) }

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
