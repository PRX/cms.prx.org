require 'test_helper'

describe User do
  let (:user) { create(:user) }
  let (:network) { create(:network, account: user.individual_account) }

  it 'has a table defined' do
    User.table_name.must_equal 'users'
  end

  it 'has a name' do
    user.name.must_equal 'Rick Astley'
  end

  it 'has a default account' do
    user.default_account.wont_be_nil
  end

  it 'creates an individual account on user create' do
    new_user = User.create(first_name: 'New', last_name: 'User', login: 'newuser')
    new_user.run_callbacks(:commit)
    new_user.individual_account.wont_be_nil
  end

  it 'has an individual account' do
    user.individual_account.wont_be_nil
  end

  it 'can update the individual account' do
    current_account = user.individual_account
    user.individual_account = create(:individual_account, opener: user)
    user.individual_account.wont_equal current_account
    user.memberships.length.must_equal 1
  end

  it 'has a list of accounts' do
    user.accounts.must_include user.individual_account
  end

  it 'has a list of networks' do
    user.networks.must_include network
  end

  it 'validates uniqueness of login' do
    user1 = create(:user)
    user2 = build(:user, login: user1.login)

    user2.wont_be :valid?
  end
end
