require 'test_helper'

describe GroupAccount do

  let(:account) { create(:group_account) }
  let(:unpublished_story) do
    create(:story, account: account, published_at: nil)
  end

  it 'has stories' do
    account.stories.count.must_be :>, 0
  end

  it 'has name as short name' do
    account.short_name.must_equal account.name
  end

  it 'has playlists' do
    account.must_respond_to :playlists
  end

  it 'has a portfolio' do
    account.must_respond_to :portfolio
  end
end
