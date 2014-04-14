# encoding: utf-8

require 'test_helper'

require 'account' if !defined?(AudioFile)

describe Api::AccountRepresenter do

  let(:account)  { FactoryGirl.create(:account) }
  let(:representer) { Api::AccountRepresenter.new(account) }
  let(:json)        { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal account.id
  end

  describe "individual accounts" do

    let(:individual_account)  { FactoryGirl.create(:individual_account) }
    let(:ia_representer) { Api::AccountRepresenter.new(account) }
    let(:json)        { JSON.parse(representer.to_json) }

  end

end
