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

  it 'includes templates' do
    json['_links']['prx:audio-version-templates'].wont_be_nil
  end

  it 'includes stories search links' do
    json['_links']['prx:stories-search'].wont_be_nil
    json['_links']['prx:stories-search']['href'].must_match "series/#{series.id}/stories/search"
  end

  it 'can set the account' do
    series.account_id.wont_be_nil
    series_hash = { title: 'Title', set_account_uri: 'api/v1/accounts/123' }
    s_representer = Api::SeriesRepresenter.new(Series.new)
    s_series = s_representer.from_json(series_hash.to_json)
    s_series.title.must_equal 'Title'
    s_series.account_id.must_equal 123
  end
end
