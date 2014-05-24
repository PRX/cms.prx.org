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

  it 'can be retrieved by tag' do
    tag = 'tag'
    picklist = create(:pick_list, :path => tag)
    other_picklist = create(:pick_list, :path => 'other tag')
    pick = create(:pick, :pick_list => picklist)
    other_pick = create(:pick, :pick_list => other_picklist)
    picks = Pick.tagged(tag)
    picks.include?(pick).must_equal true
    picks.include?(other_pick).must_equal false
  end

end
