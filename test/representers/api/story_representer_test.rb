# encoding: utf-8

require 'test_helper'
require 'story' if !defined?(Story)

describe Api::StoryRepresenter do

  let(:story)       { build_stubbed(:story_with_audio, audio_versions_count: 1, id: 212) }
  let(:representer) { Api::StoryRepresenter.new(story) }
  let(:json)        { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal story.id
  end

  it 'does not serialize a length property' do
    json.keys.wont_include('length')
  end

  it 'serializes the length of the story as duration' do
    story.length = 666
    json['duration'].must_equal 666
  end

  it 'serializes the default image' do
    image = create(:story_image)
    story.stub(:default_image, image) do
      json['_links']['prx:image']['href'].must_match /#{image.id}/
    end
  end

  it 'will not serialize default image when not available' do
    story.stub(:default_image, nil) do
      json['_links'].keys.wont_include 'prx:image'
    end
  end

end
