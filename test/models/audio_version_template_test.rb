require 'test_helper'

describe AudioVersionTemplate do

  let(:audio_version_template) do
    create(:audio_version_template, series: build(:series), length_minimum: 70)
  end
  let(:audio_version) { create(:audio_version, audio_version_template: audio_version_template) }
  let(:audio_file) { create(:audio_file, audio_version: audio_version) }

  it 'has a table defined' do
    AudioVersionTemplate.table_name.must_equal 'audio_version_templates'
  end

  it 'has a series' do
    audio_version_template.series.wont_be_nil
  end

  it 'can be created with valid attributes' do
    audio_version_template.must_be :valid?
  end

  it 'can tell if version doesnt have enough segments' do
    audio_version_template.segment_count = 2
    error_results = audio_version_template.validate_audio_version(audio_version)
    error_results.must_include 'has 1 file but must have 2 files'
  end

  it 'can tell if version length doesnt match template' do
    error_results = audio_version_template.validate_audio_version(audio_version)
    error_results.must_include 'long but must be 1 minute and 10 seconds - 1 minute and'
  end

  it 'validates with just a minimum' do
    audio_version_template.update(length_minimum: 120, length_maximum: 0)
    error_results = audio_version_template.validate_audio_version(audio_version)
    error_results.must_include 'long but must be more than 2 minutes'
  end

  it 'does not validate anything if all 0s' do
    audio_version_template.update(length_minimum: 0, length_maximum: 0)
    audio_version_template.validate_audio_version(audio_version).must_be(:nil?)
  end

  it 'leaves a file alone if file complies with template' do
    audio_version_template.length_minimum = 0
    audio_version_template.validate_audio_version(audio_version).must_be(:nil?)
  end

  it 'checks template min against max' do
    audio_version_template.length_minimum = 20
    audio_version_template.length_maximum = 10
    audio_version_template.wont_be :valid?
  end

  it 'allows template max to be unset' do
    audio_version_template.length_minimum = 20
    audio_version_template.length_maximum = 0
    audio_version_template.must_be :valid?
  end

  it 'strictly validates audio/mpeg type' do
    audio_version_template.content_type.must_equal AudioFile::MP3_CONTENT_TYPE
    audio_file.content_type.must_equal AudioFile::MP3_CONTENT_TYPE
    audio_version_template.validate_audio_file(audio_file).must_be(:nil?)

    audio_file.content_type = 'audio/mp4'
    audio_version_template.validate_audio_file(audio_file).must_include 'is not an mp3'

    audio_version_template.content_type = 'audio/foobar'
    audio_version_template.validate_audio_file(audio_file).must_be(:nil?)

    audio_version_template.content_type = AudioFile::VIDEO_CONTENT_TYPE
    audio_version_template.validate_audio_file(audio_file).must_include 'is not in video format'
  end

  it 'updates segment count when child file templates change' do
    audio_version_template.audio_file_templates.count.must_equal 0
    audio_version_template.segment_count.must_be_nil

    audio_version_template.audio_file_templates.create!(label: 'seg1')
    audio_version_template.audio_file_templates.create!(label: 'seg2')
    audio_version_template.audio_file_templates.count.must_equal 2
    audio_version_template.reload.segment_count.must_equal 2
  end

end
