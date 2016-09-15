require 'test_helper'

describe AudioFileTemplate do

  let(:audio_file_template) { create(:audio_file_template) }

  it 'has a table defined' do
    AudioFileTemplate.table_name.must_equal 'audio_file_templates'
  end

  it 'has a version template' do
    audio_file_template.audio_version_template.wont_be_nil
  end
end
