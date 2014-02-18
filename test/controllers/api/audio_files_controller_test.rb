require 'test_helper'

describe Api::AudioFilesController do

  let(:audio_file) { FactoryGirl.create(:audio_file) }

  it 'should show' do
    get(:show, { api_version: 'v1', format: 'json', id: audio_file.id } )
    assert_response :success
  end

end
