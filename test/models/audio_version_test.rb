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

  describe 'checks files are in order' do
    let(:av) { create(:audio_version, audio_files_count: 4) }

    it 'validates audio files position missing' do
      av.audio_files.destroy(av.audio_files[1])
      av.save!
      av.status.must_equal 'invalid'
      av.status_message.must_equal 'Audio file missing for position 2'
    end
  end

  describe 'checks that files match' do
    let(:av) { create(:audio_version, audio_files_count: 4) }

    it 'validates audio files match on channel' do
      av.audio_files.first.update_column(:channel_mode, 'STEREO')
      av.audio_files.last.update_column(:channel_mode, 'SINGLE_CHANNEL')
      # triggering status check; normally this would happen via the audio callback worker
      # changing the status on an audio file's status from UPLOADED to COMPLETE
      # and triggering the file's own status check + :after_save callback up the chain
      av.send(:set_status)
      av.status_message.wont_be_nil
      av.status.must_equal 'invalid'
    end

    it 'validates audio files match on frequency' do
      sample_freq = av.audio_files.first.frequency
      av.audio_files.first.update_column(:frequency, sample_freq + 1)
      av.audio_files.last.update_column(:frequency, sample_freq - 1)
      av.send(:set_status)
      av.status_message.wont_be_nil
      av.status.must_equal 'invalid'
    end

    it 'validates audio files match on bitrate' do
      av.audio_files.first.update_column(:bit_rate, 320)
      av.audio_files.last.update_column(:bit_rate, 256)
      av.send(:set_status)
      av.status_message.wont_be_nil
      av.status.must_equal 'invalid'
    end

    it 'validates audio files match on content type' do
      av.audio_files.first.update_column(:content_type, 'audio/mpeg')
      av.audio_files.last.update_column(:content_type, 'audio/x-wav')
      av.send(:set_status)
      av.status_message.wont_be_nil
      av.status.must_equal 'invalid'
    end

    it 'validates audio files match on layer' do
      av.audio_files.first.update_column(:layer, 2)
      av.audio_files.last.update_column(:layer, 3)
      av.send(:set_status)
      av.status_message.wont_be_nil
      av.status.must_equal 'invalid'
    end
  end

  describe 'with a template' do

    let(:audio_version_with_template) { create(:audio_version_with_template) }
    let(:audio_file) { create(:audio_file, status_message: 'Foo bar', status: 'uploaded') }

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
      audio_version_with_template.update_attributes(explicit: 'explicit')
      audio_version_with_template.status_message.must_include 'long but must be'
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

    it 'shows self as invalid if any audio file is not found or failed' do
      audio_file.update(status: 'not found', status_message: 'Was really not found')
      audio_version_with_template.audio_files << audio_file
      audio_version_with_template.update_attributes(explicit: 'explicit')
      audio_version_with_template.status_message.must_include 'not found'
      audio_version_with_template.status.must_equal 'invalid'
      audio_version_with_template.wont_be(:compliant_with_template?)

      audio_file.update(status: 'failed', status_message: 'Well that failed to process')
      audio_version_with_template.audio_files << audio_file
      audio_version_with_template.update_attributes(explicit: 'explicit')
      audio_version_with_template.status_message.must_include 'failed to process'
      audio_version_with_template.status.must_equal 'invalid'
      audio_version_with_template.wont_be(:compliant_with_template?)
    end
  end
end
