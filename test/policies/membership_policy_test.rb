require 'test_helper'

describe MembershipPolicy do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:mem1) { create(:membership, user: user1) }
  let(:account) { mem1.account }
  let(:mem2) { create(:membership, account: account, user: user2) }

  describe '#update?' do
    it 'returns true if user is admin' do
      MembershipPolicy.new(user1, mem2).must_allow :update?
    end

    it 'returns false if user is not a member' do
      MembershipPolicy.new(create(:user), mem1).wont_allow :update?
    end

    it 'returns false if user is not an admin' do
      MembershipPolicy.new(user2, mem1).wont_allow :update?
    end

    it 'returns false if user is not present' do
      MembershipPolicy.new(nil, mem1).wont_allow :update?
    end
  end

  describe '#destroy?' do
    it 'returns true if user is the member' do
      MembershipPolicy.new(user1, mem1).must_allow :destroy?
    end

    it 'returns true if user is an admin' do
      MembershipPolicy.new(user1, mem2).must_allow :destroy?
    end

    it 'returns false otherwise' do
      MembershipPolicy.new(user2, mem1).wont_allow :destroy?
    end
  end
end
