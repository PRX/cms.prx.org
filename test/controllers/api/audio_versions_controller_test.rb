require 'test_helper'

describe Api::AudioVersionsController do
  let(:user) { create(:user) }
  let(:story) { create(:story, account: user.individual_account) }
  let(:audio_version) { create(:audio_version, story: story) }

  it 'should show' do
    get(:show, { api_version: 'v1', format: 'json', id: audio_version.id } )
    assert_response :success
  end

  it 'should list' do
    audio_version.id.wont_be_nil
    get(:index, { api_version: 'v1', format: 'json' } )
    assert_response :success
  end
end
