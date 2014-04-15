# encoding: utf-8

require 'test_helper'

require 'membership' if !defined?(AudioFile)

describe Api::MembershipRepresenter do

  let(:membership)  { FactoryGirl.create(:membership) }
  let(:representer) { Api::MembershipRepresenter.new(membership) }
  let(:json)        { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal membership.id
  end

end
