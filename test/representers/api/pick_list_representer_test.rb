require 'test_helper'
require 'pick_list' if !defined?(PickList)

describe Api::PickListRepresenter do

  let(:pick_list)    { FactoryGirl.create(:pick_list) }
  let(:representer) { Api::PickListRepresenter.new(pick_list) }
  let(:json)        { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal pick_list.id
  end

end
