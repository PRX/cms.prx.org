require 'test_helper'

describe Api::PickListsController do

  it 'sets the pick list when given a name' do
    picklist = create(:pick_list, :path => 'name')
    get(:show, { api_version: 'v1', format: 'json', id: 'name' } )
    assigns(:pick_list).must_equal picklist
  end

  it 'sets the pick when given an id' do
    picklist = create(:pick_list, :id => 1)
    get(:show, { api_version: 'v1', format: 'json', id: 1 } )
    assigns(:pick_list).must_equal picklist
  end

  it 'does not get un-named picklists' do
    picklist = create(:pick_list, :path => nil)
    get(:index, {api_version: 'v1', format: 'json'})
    assert !assigns(:pick_lists).include?(picklist)
  end

end
