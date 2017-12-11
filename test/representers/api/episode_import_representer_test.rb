# encoding: utf-8

require 'test_helper'

describe Api::EpisodeImportRepresenter do
  let(:episode_import) { FactoryGirl.create(:episode_import) }
  let(:representer) { Api::EpisodeImportRepresenter.new(episode_import) }
  let(:json) { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal episode_import.id
  end
end
