require 'test_helper'

describe Account do

  let(:account) { FactoryGirl.create(:account) }

  it 'has a table defined' do
    Account.table_name.must_equal 'accounts'
  end

  it 'has stories' do
    account.stories.count.must_be :>, 0
  end

  it 'has first name as short name if it is an individual account' do
    user = build_stubbed(:user, {:first_name => 'sigil'})
    individual = build_stubbed(:account, {:type => 'IndividualAccount', :opener => user})
    individual.short_name.must_equal 'sigil'
  end

  it 'has call letters as short name if it is a station account' do
    station = build_stubbed(:account, {:type => 'StationAccount', :station_call_letters => 'sigil'})
    station.short_name.must_equal 'sigil'
  end

  it 'has account name as short name if it s a group account' do
    group = build_stubbed(:account, {:type => 'GroupAccount', :name => 'sigil'})
    group.short_name.must_equal 'sigil'
  end

end
