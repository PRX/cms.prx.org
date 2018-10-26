require 'test_helper'

describe AccountPolicy do
  let(:admin_token) { StubToken.new(account.id, ['admin']) }
  let(:member_token) { StubToken.new(account.id, ['member', 'account:write']) }
  let(:non_member_token) { StubToken.new(account.id + 2, ['admin']) }
  let(:member_without_write_token) { StubToken.new(account.id, ['member']) }
  let(:account) { build_stubbed(:account) }

  describe '#create?' do
    it 'returns true if user exists and has write scope' do
      AccountPolicy.new(member_token, account).must_allow :create?
    end

    it 'returns false if member does not have write scope' do
      AccountPolicy.new(member_without_write_token, account).wont_allow :create?
    end

    it 'returns false if user is not present' do
      AccountPolicy.new(nil, account).wont_allow :create?
    end
  end

  describe '#update?' do
    it 'returns false if user is not present' do
      AccountPolicy.new(nil, account).wont_allow :update?
    end

    it 'returns false if user is not an approved member' do
      AccountPolicy.new(non_member_token, account).wont_allow :update?
    end

    it 'returns true if user is a member of the account' do
      AccountPolicy.new(member_token, account).must_allow :update?
    end
  end

  describe '#destroy?' do
    it 'returns true if user is an admin' do
      AccountPolicy.new(admin_token, account).must_allow :destroy?
    end

    it 'returns false if user is not an admin' do
      AccountPolicy.new(member_token, account).wont_allow :destroy?
    end
  end
end
