require 'test_helper'
require 'audio_version' if !defined?(AudioVersion)

describe Api::AudioVersionRepresenter do

  let(:audio_version) { FactoryGirl.create(:audio_version) }
  let(:representer)   { Api::AudioVersionRepresenter.new(audio_version) }
  let(:json)          { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal audio_version.id
  end

end
