# encoding: utf-8

require 'test_helper'
require 'audio_file' if !defined?(AudioFile)

describe Api::AudioFileRepresenter do

  let(:audio_file)  { FactoryGirl.create(:audio_file) }
  let(:representer) { Api::AudioFileRepresenter.new(audio_file) }
  let(:json)        { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal audio_file.id
  end

  it 'serializes the length of the story as duration' do
    audio_file.stub(:duration, 123) do
      json['duration'].must_equal 123
    end
  end

end
