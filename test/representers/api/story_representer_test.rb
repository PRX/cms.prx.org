# encoding: utf-8

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

  it 'does not serialize a length property' do
    json.keys.wont_include('length')
  end

  it 'serializes the length of the story as duration' do
    story.length = 666
    json['duration'].must_equal 666
  end

  it 'takes content advisory from audio version' do
    json['contentAdvisory'].must_equal story.default_audio_version.content_advisory
  end

  it 'produces a null content advisory when there is no default audio version' do
    story.audio_versions = []
    json['contentAdvisory'].must_be_nil
  end

end
