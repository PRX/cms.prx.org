# encoding: utf-8

require 'test_helper'
require 'license' if !defined?(License)

describe Api::LicenseRepresenter do

  let(:license)     { FactoryGirl.create(:story).license }
  let(:representer) { Api::LicenseRepresenter.new(license) }
  let(:json)        { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal license.id
  end

end
