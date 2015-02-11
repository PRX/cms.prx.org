# encoding: utf-8

require 'test_helper'
require 'musical_work' if !defined?(AudioFile)

describe Api::MusicalWorkRepresenter do

  let(:musical_work)  { FactoryGirl.create(:musical_work) }
  let(:representer)   { Api::MusicalWorkRepresenter.new(musical_work) }
  let(:json)          { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal musical_work.id
  end

  it 'will have a nested self link' do
    self_href = "/api/v1/stories/#{musical_work.story.id}/musical_works/#{musical_work.id}"
    json['_links']['self']['href'].must_equal self_href
  end

  it 'serializes the length of the story as duration' do
    musical_work.stub(:duration, 123) do
      json['duration'].must_equal 123
    end
  end
end
