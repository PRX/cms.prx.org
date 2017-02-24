require 'test_helper'

describe AudioFileTemplate do

  let(:audio_file_template) { create(:audio_file_template) }
  let(:audio_file) { create(:audio_file, label: 'Main Segment', position: 1) }

  it 'has a table defined' do
    AudioFileTemplate.table_name.must_equal 'audio_file_templates'
  end

  it 'has a version template' do
    audio_file_template.audio_version_template.wont_be_nil
  end

  it 'can tell if file length doesnt match template' do
    audio_file_template.validate_audio_file(audio_file).must_include 'long, but must be'
  end

  it 'leaves a file alone if file complies with template' do
    audio_file.update(length: 5)
    audio_file_template.validate_audio_file(audio_file).must_be(:empty?)
  end
end
