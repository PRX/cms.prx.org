require 'test_helper'

describe User do
  let(:user) { build(:user) }

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

  describe '#role_for' do
    let(:membership) { create(:membership, user: user) }
    let(:account) { membership.account }

    it 'returns the role for a particular account' do
      user.role_for(account).must_equal membership.role
    end

    it 'returns nil if the user is not a part of the account' do
      create(:user).role_for(account).must_be_nil
    end
  end
end
