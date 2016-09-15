# encoding: utf-8

require 'test_helper'
require 'audio_version_template' if !defined?(AudioVersionTemplate)

describe Api::AudioVersionTemplateRepresenter do
  let(:audio_version_template) { create(:audio_version_template) }
  let(:representer) { Api::AudioVersionTemplateRepresenter.new(audio_version_template) }
  let(:json) { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal audio_version_template.id
  end
end
