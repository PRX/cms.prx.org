# encoding: utf-8

require 'test_helper'
require 'audio_file_template' if !defined?(AudioFileTemplate)

describe Api::AudioFileTemplateRepresenter do
  let(:audio_file_template) { create(:audio_file_template) }
  let(:representer) { Api::AudioFileTemplateRepresenter.new(audio_file_template) }
  let(:json) { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal audio_file_template.id
  end
end
