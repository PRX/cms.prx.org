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

  it 'passes through streamable attribute' do
    license.stub(:streamable, 1) do
      json['streamable'].must_equal 1
    end
  end

  it 'passes through the editable attribute' do
    license.stub(:editable, 2) do
      json['editable'].must_equal 2
    end
  end

end
