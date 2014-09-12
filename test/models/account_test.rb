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

end
