require 'test_helper'

describe AudioVersion do

  let(:audio_version) { create(:audio_version, audio_files_count: 1) }

  it 'has a table defined' do
    AudioVersion.table_name.must_equal 'audio_versions'
  end

  it 'has a length from audio files' do
    audio_version.audio_files.inject(0){|sum, af| sum += af.length}.must_equal 60
    audio_version.length(true).must_equal 60
  end

  it 'has length and duration' do
    audio_version.length(true).must_equal audio_version.duration
  end

  it 'can have a template' do
    audio_version = create(:audio_version_with_template)
    audio_version.audio_version_template(true).wont_be_nil
  end
end
