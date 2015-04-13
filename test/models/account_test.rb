require 'test_helper'

describe Account do

  let(:account) { create(:account) }

  it 'has a table defined' do
    Account.table_name.must_equal 'accounts'
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

  describe '#portfolio_stories' do
    it 'returns only stories in portfolio' do
      portfolio = create(:portfolio, account: account)
      section = create(:playlist_section, playlist: portfolio)
      pick1 = create(:pick, playlist_section: section)
      pick2 = create(:pick)

      account.portfolio_stories.must_include pick1.story
      account.portfolio_stories.wont_include pick2.story
    end

    it 'returns empty list when there is no portfolio' do
      account = create(:account)
      account.portfolio.must_be_nil
      account.portfolio_stories.size.must_equal 0
    end
  end
end
