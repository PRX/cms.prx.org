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

  describe 'with a template' do

    let(:audio_version_with_template) { create(:audio_version_with_template) }

    it 'can have a template' do
      audio_version_with_template.audio_version_template(true).wont_be_nil
    end

    it 'validates self against template before save' do
      audio_version_with_template.update_attributes(explicit: 'explicit')
      audio_version_with_template.file_errors.must_include 'must be between'
      audio_version_with_template.status.must_equal 'invalid'
      audio_version_with_template.wont_be(:compliant_with_template?)
    end
  end
end
