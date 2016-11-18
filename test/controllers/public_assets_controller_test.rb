require 'test_helper'

describe PublicAssetsController do

  let(:audio_file) { FactoryGirl.create(:audio_file) }

  it 'should get unauthorized for invalid request' do
    get(:show,
      {
        token: 'badtoken',
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

  it 'should get redirected to asset for valid request' do
    options = audio_file.set_asset_option_defaults
    options[:token] = audio_file.public_url_token(options)

    get(:show, options)

    assert_response :redirect
  end

  it 'should get redirected to asset for valid HEAD request' do
    options = audio_file.set_asset_option_defaults
    options[:token] = audio_file.public_url_token(options)

    get(:show_head, options)

    assert_response :redirect
  end

  it 'has no content for options requests' do
    options = audio_file.set_asset_option_defaults
    options[:token] = audio_file.public_url_token(options)

    process :show_options, 'OPTIONS', options

    response.status.must_equal 204
  end

end
