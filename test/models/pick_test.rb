require 'test_helper'

describe Pick do

  let(:pick) { FactoryGirl.create(:pick) }

  it 'has a table defined' do
    Pick.table_name.must_equal 'playlistings'
  end

  it 'has a story' do
    pick.story.wont_be_nil
  end

  it 'has a pick list' do
    pick.pick_list.wont_be_nil
  end

  it 'has an account' do
    pick.account.wont_be_nil
  end

end
