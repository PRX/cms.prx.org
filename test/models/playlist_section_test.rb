require 'test_helper'

describe PlaylistSection do

  let(:playlist_section) { FactoryGirl.create(:playlist_section) }

  it 'has a table defined' do
    PlaylistSection.table_name.must_equal 'playlist_sections'
  end

  it 'has a pick list' do
    playlist_section.pick_list.wont_be_nil
  end

  it 'has an account' do
    playlist_section.account.wont_be_nil
  end

end

