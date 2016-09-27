# encoding: utf-8

require 'test_helper'
require 'account' if !defined?(Account)

describe Api::Min::AccountRepresenter do
  let(:account) { create(:account) }
  let(:representer) { Api::Min::AccountRepresenter.new(account) }
  let(:json) { JSON.parse(representer.to_json) }

  it 'use representer to create json' do
    json['id'].must_equal account.id
  end

  it 'includes short name in json' do
    json['shortName'].must_equal account.short_name
  end
end
