require 'test_helper'

describe AudioVersionTemplate do

  let(:audio_version_template) { create(:audio_version_template) }

  it 'has a table defined' do
    AudioVersionTemplate.table_name.must_equal 'audio_version_templates'
  end

  it 'has a series' do
    audio_version_template.series.wont_be_nil
  end

  it 'can be created with valid attributes' do
    audio_version_template.must_be :valid?
  end

  it 'reduce file templates when segment count lowered' do
    audio_version_template.segment_count.must_equal 4
    audio_version_template.audio_file_templates.count.must_equal 4
    audio_version_template.segment_count = 2
    audio_version_template.save
    audio_version_template.audio_file_templates(true).count.must_equal 2
  end

  it 'add file templates when segment count raised' do
    audio_version_template.segment_count.must_equal 4
    audio_version_template.audio_file_templates.count.must_equal 4
    audio_version_template.segment_count = 6
    audio_version_template.save
    audio_version_template.audio_file_templates(true).count.must_equal 6
  end
end
