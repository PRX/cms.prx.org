require 'test_helper'

describe PickList do

  let(:pick_list) { build_stubbed(:pick_list) }

  it 'has a table defined' do
    PickList.table_name.must_equal 'playlists'
  end

  it 'has an account' do
    pick_list.must_respond_to 'account'
  end

end

