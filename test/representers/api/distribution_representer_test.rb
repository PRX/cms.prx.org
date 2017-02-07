# encoding: utf-8

require 'test_helper'
require 'distribution' if !defined?(Distribution)

describe Api::DistributionRepresenter do
  let(:audio_version_template) { create(:audio_version_template) }
  let(:distribution) do
    FactoryGirl.create(:distribution, audio_version_template: audio_version_template)
  end
  let(:representer)   { Api::DistributionRepresenter.new(distribution) }
  let(:json)          { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal distribution.id
    json['properties']['explicit'].must_equal 'clean'
  end

  it 'doesnt link to the template if the template has been destroyed' do
    representer.represented.audio_version_template.destroy!
    representer.represented.reload
    json['_links']['prx:audio-version-template'].must_be_nil
  end
end
