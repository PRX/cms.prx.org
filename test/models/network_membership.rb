require 'test_helper'

describe NetworkMembership do
  let(:network_membership) { create(:network_membership) }

  it 'has a table defined' do
    NetworkMembership.table_name.must_equal 'network_memberships'
  end

  it 'can create a valid network membership' do
    network_membership.network.wont_be_nil
    network_membership.account.wont_be_nil
  end
end
