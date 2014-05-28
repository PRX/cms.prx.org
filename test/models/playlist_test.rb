require 'test_helper'

describe Playlist do

  let(:playlist) { build_stubbed(:playlist) }

  it 'has an account' do
    playlist.must_respond_to 'account'
  end

end

