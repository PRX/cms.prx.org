# encoding: utf-8

require 'test_helper'
require 'series' if !defined?(Series)

describe Api::Min::StoryRepresenter do
  let(:story) { create(:story, audio_versions_count: 1) }
  let(:representer) { Api::Min::StoryRepresenter.new(story) }
  let(:json) { JSON.parse(representer.to_json) }

  it 'can serialize an unsaved story' do
    json = Api::Min::StoryRepresenter.new(story).to_json
    json.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal story.id
  end

  it 'has a story profile' do
    json['_links']['profile']['href'].must_equal 'http://meta.prx.org/model/story/min'
  end

  it 'serializes the length of the story as duration' do
    story.stub(:duration, 212) do
      json['duration'].must_equal 212
    end
  end

  it 'includes story status' do
    json['status'].wont_be_nil
  end
end
