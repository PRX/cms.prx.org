require 'test_helper'

describe Portfolio do
  let(:portfolio) { build_stubbed(:portfolio) }

  it 'is a type of playlist' do
    portfolio.must_be_kind_of Playlist
  end

  it 'belongs to an account' do
    portfolio.must_respond_to :account
  end
end
