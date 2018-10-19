require 'test_helper'

describe Account do
  should validate_presence_of(:path)
  should validate_length_of(:path).is_at_least(1)
  should validate_length_of(:path).is_at_most(40)
  should allow_value('path_mcgee').for(:path)
  should allow_value('path_mcgee-the-3rd').for(:path)
  should_not allow_value('Path McGee').for(:path)
  should_not allow_value('excited_user!').for(:path)

  let(:account) { create(:account) }
  let(:unpublished_story) do
    create(:story, account: account, published_at: nil)
  end

  it 'fails if path is a reserved word' do
    a = Account.new(name: 'name', path: ROUTE_RESERVED_WORDS.sample)
    a.validate
    refute(a.errors[:path].empty?)
    assert(a.errors[:path].include? "has already been taken")
  end

  it 'has a table defined' do
    Account.table_name.must_equal 'accounts'
  end

  it 'has stories' do
    account.stories.count.must_be :>, 0
  end

  it 'does not include unpublished stories in public_stories' do
    account.public_stories.where(id: unpublished_story.id).count.must_equal 0
  end

  it 'has unpublished (or any) stories' do
    account.stories.where(id: unpublished_story.id).count.must_equal 1
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
