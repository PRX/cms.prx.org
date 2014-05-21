require 'test_helper'
require 'pick' if !defined?(Pick)

describe Api::PickRepresenter do

  let(:pick)    { FactoryGirl.create(:pick) }
  let(:representer) { Api::PickRepresenter.new(pick) }
  let(:json)        { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal pick.id
  end

end
