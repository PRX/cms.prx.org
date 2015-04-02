# encoding: utf-8

require 'test_helper'
require 'address' if !defined?(AudioFile)

describe Api::AddressRepresenter do

  let(:address) { create(:account).address }
  let(:representer) { Api::AddressRepresenter.new(address) }
  let(:json) { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal address.id
  end
end
