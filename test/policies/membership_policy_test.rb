require 'test_helper'

describe MembershipPolicy do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:mem1) { create(:membership, user: user1) }
  let(:account) { mem1.account }
  let(:mem2) { create(:membership, account: account, user: user2) }

  describe '#update?' do
    it 'returns true if user is admin' do
      assert MembershipPolicy.new(user1, mem2).update?
    end

    it 'returns false if user is not a member' do
      assert !MembershipPolicy.new(user1, build_stubbed(:membership)).update?
    end

    it 'returns false if user is not an admin' do
      assert !MembershipPolicy.new(user2, mem1).update?
    end

    it 'returns false if user is not present' do
      assert !MembershipPolicy.new(nil, mem1).update?
    end
  end

  describe '#destroy?' do
    it 'returns true if user is the member' do
      assert MembershipPolicy.new(user1, mem1).destroy?
    end

    it 'returns true if user is an admin' do
      assert MembershipPolicy.new(user1, mem2).destroy?
    end

    it 'returns false otherwise' do
      assert !MembershipPolicy.new(user2, mem1).destroy?
    end
  end
end
