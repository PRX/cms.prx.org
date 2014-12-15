require 'test_helper'

describe Api::AudioFilesController do
  let(:user) { create(:user) }
  let(:story) { create(:story, account: user.individual_account) }
  let(:audio_file) { create(:audio_file, story: story) }

  it 'should show' do
    get :show, id: audio_file.id, format: 'json', api_version: 'v1'
    assert_response :success
  end

  it 'should list for version' do
    audio_file.id.wont_be_nil
    get(:index, audio_version_id: audio_file.audio_version_id, api_version: 'v1', format: 'json' )
    assert_response :success
  end

  it 'should list for story' do
    audio_file.id.wont_be_nil
    get(:index, story_id: story.id, api_version: 'v1', format: 'json' )
    assert_response :success
  end

end
