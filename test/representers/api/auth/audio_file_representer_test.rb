# encoding: utf-8

require 'test_helper'
require 'audio_file' if !defined?(AudioFile)

describe Api::Auth::AudioFileRepresenter do

  let(:audio_file)  { create(:audio_file) }
  let(:representer) { Api::Auth::AudioFileRepresenter.new(audio_file) }
  let(:json)        { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal audio_file.id
  end

  it 'links to the s3 storage' do
    store = json['_links']['prx:storage']['href']
    store.must_equal "s3://#{ENV['AWS_BUCKET']}/public/audio_files/#{audio_file.id}/test.mp2"
  end

  it 'reveals the analyzed audio format' do
    json['contentType'].must_equal 'audio/mpeg'
    json['layer'].must_equal 2
    json['frequency'].must_equal '44.1'
    json['bitRate'].must_equal 128
    json['channelMode'].must_equal 'Single Channel'
  end
end
