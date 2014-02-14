require 'test_helper'

describe PublicAssetsController do

  let(:audio_file) { FactoryGirl.create(:audio_file) }

  it 'should get unauthorized for bad token' do
    get(:show,
      {
        token: '',
        expires: '0',
        use: 'web',
        class: 'audio_file',
        id: audio_file.id,
        version: 'download',
        name: 'test',
        extension: 'mp3'
      }
    )

    assert_response :unauthorized
  end

end
