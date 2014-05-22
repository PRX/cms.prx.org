require 'test_helper'

describe Pick do

  let(:pick) { build_stubbed(:pick) }

  it 'has a table defined' do
    Pick.table_name.must_equal 'playlistings'
  end

  it 'has a story' do
    pick.must_respond_to 'story'
  end

  it 'has a pick list' do
    pick.must_respond_to 'pick_list'
  end

  it 'has an account' do
    pick.must_respond_to 'account'
  end

end
