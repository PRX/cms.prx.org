require 'test_helper'

describe Api::AudioVersionsController do

  let(:audio_version) { FactoryGirl.create(:audio_version) }

  it 'should show' do
    get(:show, { api_version: 'v1', format: 'json', id: audio_version.id } )
    assert_response :success
  end

end
