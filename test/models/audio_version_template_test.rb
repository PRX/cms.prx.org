require 'test_helper'

describe AudioVersionTemplate do

  let(:audio_version_template) { create(:audio_version_template) }
  let(:audio_version) { create(:audio_version, audio_version_template: audio_version_template)}

  it 'has a table defined' do
    AudioVersionTemplate.table_name.must_equal 'audio_version_templates'
  end

  it 'has a series' do
    audio_version_template.series.wont_be_nil
  end

  it 'can be created with valid attributes' do
    audio_version_template.must_be :valid?
  end

  it 'can validate an audio version against itself' do
    audio_version_template.segment_count = 2
    error_results = audio_version_template.validate_audio_version(audio_version)
    error_results.must_include 'must be between'
    error_results.must_include 'has 1 audio files, but must have'
  end
end
