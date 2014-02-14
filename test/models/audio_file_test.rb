require 'test_helper'

describe AudioFile do

  let(:audio_file) { FactoryGirl.create(:audio_file) }

  it 'has a table defined' do
    AudioFile.table_name.must_equal 'audio_files'
  end

  it 'has an asset_url' do
    audio_file.asset_url.must_match "/public/audio_files/#{audio_file.id}/test.mp2"
  end

  it 'has an public_asset_filename' do
    audio_file.public_asset_filename.must_equal audio_file.filename
  end

  it 'can update the underlying file' do
    audio_file.update_file!("test2.mp3")
    audio_file.filename.must_equal "test2.mp3"
  end

end
