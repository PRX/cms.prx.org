require 'test_helper'

describe AudioVersionTemplate do

  let(:audio_version_template) { create(:audio_version_template) }

  it 'has a table defined' do
    AudioVersionTemplate.table_name.must_equal 'audio_version_templates'
  end

  it 'has a series' do
    audio_version_template.series.wont_be_nil
  end
end
