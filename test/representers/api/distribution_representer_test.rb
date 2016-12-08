# encoding: utf-8

require 'test_helper'
require 'distribution' if !defined?(Distribution)

describe Api::DistributionRepresenter do

  let(:distribution) { FactoryGirl.create(:distribution) }
  let(:representer)   { Api::DistributionRepresenter.new(distribution) }
  let(:json)          { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal distribution.id
    json['properties']['explicit'].must_equal 'clean'
  end
end
