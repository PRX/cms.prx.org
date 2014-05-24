require 'test_helper'

describe Api::PicksController do

  it 'finds restricts result to tags when a tag param provided' do
    picklist = create(:pick_list, :path => 'name')
    pick = create(:pick, :pick_list => picklist)
    other_picklist = create(:pick_list, :path => 'other_name')
    other_pick = create(:pick, :pick_list => other_picklist)
    get(:index, { api_version: 'v1', format: 'json', tag: 'name' } )
    assert assigns(:picks).include?(pick)
    assert !assigns(:picks).include?(other_pick)
  end

  it 'succeeds even when a non-existent tag is requested' do
    get(:index, { api_version: 'v1', format: 'json', tag: 'foo' } )
    assert_response :success
  end

  it 'restricts picks to the playlist when nested' do
    picklist = create(:pick_list, :path => 'name')
    pick = create(:pick, :pick_list => picklist)
    other_picklist = create(:pick_list, :path => 'other_name')
    other_pick = create(:pick, :pick_list => other_picklist)
    get(:index, { api_version: 'v1', format: 'json', pick_list_id: 'name'})
    assert assigns(:picks).include?(pick)
    assert !assigns(:picks).include?(other_pick)
  end

end
