# encoding: utf-8

require 'test_helper'

require 'series' if !defined?(AudioFile)

describe Api::SeriesRepresenter do

  let(:series)      { FactoryGirl.create(:series) }
  let(:representer) { Api::SeriesRepresenter.new(series) }
  let(:json)        { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal series.id
  end

end
