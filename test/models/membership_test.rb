require 'test_helper'

describe Membership do
  let(:membership) { create(:membership) }
  let(:user) { membership.user }

  it 'has a table defined' do
    Membership.table_name.must_equal 'memberships'
  end

  it 'sets user default account to individual if current default membership destroyed' do
    user.default_account = membership.account
    user.default_account.must_equal membership.account
    membership.destroy
    user.reload
    user.default_account.wont_equal membership.account
    user.default_account.must_equal user.default_account
  end
end
