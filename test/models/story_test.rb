require 'test_helper'
require 'story'

describe Story do

  let(:story) { FactoryGirl.create(:story_with_audio, audio_versions_count: 10) }

  it 'has a table defined' do
    Story.table_name.must_equal 'pieces'
  end

  it 'finds default audio' do
    story.default_audio
  end

end
