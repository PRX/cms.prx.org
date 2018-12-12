require 'test_helper'

describe Account do

  let(:account) { create(:account) }
  let(:unpublished_story) do
    create(:story, account: account, published_at: nil)
  end

  it 'validates path is not a reserved word' do
    reservedpath = build(:account, path: ROUTE_RESERVED_WORDS.sample)
    refute reservedpath.valid?
    assert reservedpath.errors[:path].include? 'has already been taken'
  end

  it 'validates path is not taken' do
    create(:account, path: 'takenpath')
    takenpath = build(:account, path: 'takenpath')
    refute takenpath.valid?
    assert takenpath.errors[:path].include? 'has already been taken'
  end

  it 'validates presence of path' do
    nopath = build(:account, path: nil)
    refute nopath.valid?
    assert nopath.errors[:path].include? 'can\'t be blank'
  end

  it 'validates path is long enough' do
    shortpath = build(:account, path: '')
    refute shortpath.valid?
    assert(shortpath.errors[:path].any? { |e| e.match /is too short/ })
  end

  it 'validates path is not too long' do
    longpath = build(:account, path: (1..41).map { |_i| 'a' }.join)
    refute longpath.valid?
    assert(longpath.errors[:path].any? { |e| e.match /is too long/ })
  end

  it 'allows valid path names' do
    goodpath = build(:account, path: 'path_mcgee')
    goodpath2 = build(:account, path: 'path_mcgee-the-3rd')
    assert goodpath.valid?
    assert goodpath2.valid?
  end

  it 'disallows invalid path names' do
    badpath = build(:account, path: 'Path McGee')
    badpath2 = build(:account, path: 'excited_user!')
    refute badpath.valid?
    assert(badpath.errors[:path].any? { |e| e.match /is invalid/ })
    refute badpath2.valid?
    assert(badpath2.errors[:path].any? { |e| e.match /is invalid/ })
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

  describe '.class_for_kind' do
    it 'returns appropriate individual_account class' do
      ia_class = Account.class_for_kind('individual')
      ia_class.name.must_equal 'IndividualAccount'
    end

    it 'returns appropriate group_account class' do
      ia_class = Account.class_for_kind('group')
      ia_class.name.must_equal 'GroupAccount'
    end

    it 'returns appropriate station_account class' do
      ia_class = Account.class_for_kind('station')
      ia_class.name.must_equal 'StationAccount'
    end

    it 'returns base class if no match' do
      ia_class = Account.class_for_kind('foobar')
      ia_class.name.must_equal 'Account'
    end
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
