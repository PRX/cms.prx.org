# encoding: utf-8

require 'test_helper'

require 'account' if !defined?(AudioFile)

describe Api::AccountRepresenter do

  let(:account)     { create(:account) }
  let(:representer) { Api::AccountRepresenter.new(account) }
  let(:json)        { JSON.parse(representer.to_json) }

  it 'use representer to create json' do
    json['id'].must_equal account.id
  end

  it 'includes short name in json' do
    json['shortName'].must_equal account.short_name
  end

  it 'includes external urls' do
    websites = [
      build_stubbed(:website, url: 'http://prx.org'),
      build_stubbed(:website, url: 'http://example.com')
    ]
    account.stub(:websites, websites) do
      json['_links']['prx:external'].must_include 'href' => 'http://prx.org'
      json['_links']['prx:external'].must_include 'href' => 'http://example.com'
    end
  end

end
