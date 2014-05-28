require 'test_helper'

describe Api::PicksController do

  it 'only returns picks from named playlists' do
    playlist = create(:playlist, :path => nil)
    pick = create(:pick, :playlist => playlist)
    named_playlist = create(:playlist, :path => 'name')
    named_pick = create(:pick, :playlist => named_playlist)
    get(:index, { api_version: 'v1', format: 'json' } )
    assert !assigns(:picks).include?(pick)
    assert assigns(:picks).include?(named_pick)
  end

end
