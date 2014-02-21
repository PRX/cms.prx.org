require 'test_helper'

describe Api::AudioFilesController do

  let(:audio_file) { FactoryGirl.create(:audio_file) }

  it 'should show' do
    get :show, id: audio_file.id, format: 'json', api_version: 'v1'
    assert_response :success
  end

  it 'should list' do
    audio_file.id.wont_be_nil
    get(:index, { api_version: 'v1', format: 'json' } )
    assert_response :success
  end

end
