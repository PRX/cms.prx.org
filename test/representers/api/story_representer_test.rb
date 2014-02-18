require 'test_helper'
require 'story' if !defined?(Story)

describe Api::StoryRepresenter do

  let(:story)       { FactoryGirl.create(:story_with_audio, audio_versions_count: 1) }
  let(:representer) { Api::StoryRepresenter.new(story) }
  let(:json)        { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal story.id
  end

end
