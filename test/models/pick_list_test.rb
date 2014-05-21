require 'test_helper'

describe PickList do

  let(:pick_list) { FactoryGirl.create(:pick_list) }

  it 'has a table defined' do
    PickList.table_name.must_equal 'playlists'
  end

  it 'has an account' do
    pick_list.account.wont_be_nil
  end

end

