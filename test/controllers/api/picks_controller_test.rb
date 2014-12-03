require 'test_helper'

describe Api::PicksController do
  it 'only returns picks from named playlists' do
    playlist = create(:playlist, path: 'name')
    pick = create(:pick, playlist: playlist)
    unnamed_playlist = create(:playlist, path: nil)
    unnamed_pick = create(:pick, playlist: unnamed_playlist)
    get(:index, api_version: 'v1', format: 'json')

    assert !assigns(:picks).include?(unnamed_pick)
    assert assigns(:picks).include?(pick)
  end
end
