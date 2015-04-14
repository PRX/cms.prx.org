require 'test_helper'

describe Address do

  let(:user) { create(:user) }
  let(:account) { create(:account) }

  it 'has a table defined' do
    Address.table_name.must_equal 'addresses'
  end

  it 'provides underlying account for user address' do
    user.address.account.must_equal user.individual_account
  end

  it 'provides underlying account for account address' do
    account.address.account.must_equal account
  end
end
