# encoding: utf-8

require 'test_helper'
require 'audio_version' if !defined?(AudioVersion)

describe Api::AudioVersionRepresenter do

  let(:audio_version) { FactoryGirl.create(:audio_version_with_template) }
  let(:representer)   { Api::AudioVersionRepresenter.new(audio_version) }
  let(:json)          { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal audio_version.id
  end

  describe 'explicit' do
    it 'can be yes' do
      audio_version.explicit = 'yes'
      json['explicit'].must_equal 'yes'
    end

    it 'can be clean' do
      audio_version.explicit = 'clean'
      json['explicit'].must_equal 'clean'
    end

    it 'can be blank' do
      audio_version.explicit = nil
      json['explicit'].must_equal nil
    end
  end

  it 'returns a link to the template' do
    json['_links']['prx:audio-version-template']['href'].wont_be_nil
  end

  it 'doesnt return a link to the template if there is no template' do
    representer.represented.audio_version_template_id = 'foo'
    json['_links']['prx:audio-version-template'].must_be_nil
  end
end
