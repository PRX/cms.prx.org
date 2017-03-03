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
    let(:audio_file) { create(:audio_file, status: 'invalid', status_message: 'Foo bar') }

    it 'can have a template' do
      audio_version_with_template.audio_version_template(true).wont_be_nil
    end

    it 'shows self as valid if compliant with template and all files are valid' do
      audio_version_with_template.instance_variable_set('@_length', 50)
      audio_version_with_template.update_attributes(explicit: 'explicit')
      audio_version_with_template.status_message.must_be_nil
      audio_version_with_template.status.must_equal 'complete'
      audio_version_with_template.must_be(:compliant_with_template?)
    end

    it 'shows self as invalid if incompliant with template' do
      audio_version_with_template.status_message.must_include 'long, but must be'
      audio_version_with_template.status.must_equal 'invalid'
      audio_version_with_template.wont_be(:compliant_with_template?)
    end

    it 'shows self as invalid if any audio file is invalid' do
      audio_version_with_template.audio_files << audio_file
      audio_version_with_template.update_attributes(explicit: 'explicit')
      audio_version_with_template.status_message.must_include 'Foo bar'
      audio_version_with_template.status.must_equal 'invalid'
      audio_version_with_template.wont_be(:compliant_with_template?)
    end
  end
end
