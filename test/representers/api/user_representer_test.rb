# encoding: utf-8

require 'test_helper'

require 'user' if !defined?(AudioFile)

describe Api::UserRepresenter do

  let(:user)        { FactoryGirl.create(:user) }
  let(:representer) { Api::UserRepresenter.new(user) }
  let(:json)        { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal user.id
  end

  it 'includes the default account' do
    json['_links']['prx:default-account']['href'].must_match /accounts\/#{user.default_account.id}/
  end

end
