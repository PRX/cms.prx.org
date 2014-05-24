require 'test_helper'

describe PickList do

  let(:pick_list) { build_stubbed(:pick_list) }

  it 'has a table defined' do
    PickList.table_name.must_equal 'playlists'
  end

  it 'has an account' do
    pick_list.must_respond_to 'account'
  end

  it 'can find by path or id' do
    picklist = create(:pick_list, :id => 1, :path => 'path')
    PickList.find_by_id_or_path('path').must_equal picklist
    PickList.find_by_id_or_path(1).must_equal picklist
  end

  it 'will return all named pick lists if named scope requested with no name' do
    named_picklist = create(:pick_list, :path => 'foo')
    unnamed_picklist = create(:pick_list, :path => nil)
    named = PickList.named
    assert named.include?(named_picklist)
    assert !named.include?(unnamed_picklist)
  end

  it 'will return only pick lists with specified name when named scope requested with name' do
    named_picklist = create(:pick_list, :path => 'name')
    other_picklist = create(:pick_list, :path => 'other')
    named = PickList.named('name')
    assert named.include?(named_picklist)
    assert !named.include?(other_picklist)
  end

end

