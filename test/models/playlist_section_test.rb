require 'test_helper'

describe PlaylistSection do

  let(:playlist_section) { build_stubbed(:playlist_section) }

  it 'has a pick list' do
    playlist_section.must_respond_to 'pick_list'
  end

  it 'has an account' do
    playlist_section.must_respond_to 'account'
  end

end

