require 'test_helper'

describe PlaylistSection do

  let(:playlist_section) { build_stubbed(:playlist_section) }

  it 'has a playlist' do
    playlist_section.must_respond_to 'playlist'
  end

  it 'has an account' do
    playlist_section.must_respond_to 'account'
  end

end
