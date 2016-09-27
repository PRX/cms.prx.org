require 'test_helper'

describe NetworkMembershipPolicy do
  let(:admin_account) { create(:account) }
  let(:member_account) { create(:account) }
  let(:random_account) { create(:account) }
  let(:network) { create(:network, account: admin_account) }
  let(:membership) { NetworkMembership.new(network: network, account: member_account) }

  let(:member_token) { StubToken.new(member_account.id, ['admin']) }
  let(:admin_token) { StubToken.new(admin_account.id, ['admin']) }
  let(:non_member_token) { StubToken.new(random_account, ['no']) }

  describe '#update?' do
    it 'returns true when account is network admin' do
      NetworkMembershipPolicy.new(admin_token, membership).must_allow :create?
    end

    it 'returns false if account is trying to become a member' do
      NetworkMembershipPolicy.new(member_token, membership).wont_allow :create?
    end

    it 'returns false if account is not the admin' do
      NetworkMembershipPolicy.new(non_member_token, membership).wont_allow :create?
    end
  end

  describe '#destroy?' do
    it 'returns true when account is network admin' do
      NetworkMembershipPolicy.new(admin_token, membership).must_allow :destroy?
    end

    it 'returns true if account is the member' do
      NetworkMembershipPolicy.new(member_token, membership).must_allow :destroy?
    end

    it 'returns false if account is not the admin' do
      NetworkMembershipPolicy.new(non_member_token, membership).wont_allow :destroy?
    end
  end
end
