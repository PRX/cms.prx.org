require 'test_helper'

describe MembershipPolicy do
  let(:member_token) { StubToken.new(account.id, ['account']) }
  let(:admin_token) { StubToken.new(account.id, ['account', 'account-members']) }
  let(:non_member_token) { StubToken.new(account.id + 1, ['account', 'account-members']) }
  let(:membership) { build_stubbed(:membership, user: user, account: account, approved: false) }
  let(:user) { build_stubbed(:user, id: non_member_token.user_id) }
  let(:account) { build_stubbed(:account) }

  describe '#create?' do
    describe 'when user is admin' do
      it 'returns true' do
        MembershipPolicy.new(admin_token, membership).must_allow :create?
      end
    end

    describe 'when user is not admin' do
      it 'returns false if user is not the member' do
        membership.user.id = member_token
        MembershipPolicy.new(non_member_token, membership).wont_allow :create?
      end

      it 'returns false if membership is approved' do
        membership.approved = true
        MembershipPolicy.new(non_member_token, membership).wont_allow :create?
      end

      it 'returns true otherwise' do
        MembershipPolicy.new(non_member_token, membership).must_allow :create?
      end
    end
  end

  describe '#update?' do
    it 'returns true if user is admin' do
      MembershipPolicy.new(admin_token, membership).must_allow :update?
    end

    it 'returns false if user is not a member' do
      MembershipPolicy.new(non_member_token, membership).wont_allow :update?
    end

    it 'returns false if user is not an admin' do
      MembershipPolicy.new(member_token, membership).wont_allow :update?
    end

    it 'returns false if user is not present' do
      MembershipPolicy.new(nil, membership).wont_allow :update?
    end
  end

  describe '#destroy?' do
    it 'returns true if user is the member' do
      MembershipPolicy.new(non_member_token, membership).must_allow :destroy?
    end

    it 'returns true if user is an admin' do
      MembershipPolicy.new(admin_token, membership).must_allow :destroy?
    end

    it 'returns false otherwise' do
      MembershipPolicy.new(member_token, membership).wont_allow :destroy?
    end
  end
end
