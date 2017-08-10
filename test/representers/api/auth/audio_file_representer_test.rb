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
end
