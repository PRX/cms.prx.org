require 'test_helper'

describe Api::AudioFilesController do

  let(:audio_file) { FactoryGirl.create(:audio_file) }

  it 'should show' do
    get :show, id: audio_file.id, format: 'json', api_version: 'v1'
    assert_response :success
  end

end
