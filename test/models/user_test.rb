require 'test_helper'

describe User do

  let(:user) { FactoryGirl.create(:user) }

  it 'has a table defined' do
    User.table_name.must_equal 'users'
  end

  it 'has a name' do
    user.name.must_equal 'Rick Astley'
  end

  it 'has a default account' do
    user.default_account.wont_be_nil
  end

  it 'has an individual account' do
    user.individual_account.wont_be_nil
  end

  it 'has a list of accounts' do
    user.accounts.must_equal [user.individual_account]
  end

end
