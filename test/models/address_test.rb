require 'test_helper'

describe Address do

  let(:user) { create(:user) }
  let(:account) { create(:account) }
  let(:address) { account.address }

  it 'has a table defined' do
    Address.table_name.must_equal 'addresses'
  end

  it 'provides underlying account for user address' do
    user.address.account.must_equal user.individual_account
  end

  it 'provides underlying account for account address' do
    address.account.must_equal account
  end

  it 'can set an account' do
    address.account = user.address.account
    address.account.must_equal user.address.account
  end

  it 'has policy based on account' do
    Address.policy_class.must_equal AccountablePolicy
  end
end
