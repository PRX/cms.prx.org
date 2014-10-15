require 'test_helper'

describe AccountPolicy do
  let(:user) { build_stubbed(:user) }
  let(:user2) { build_stubbed(:user) }
  let(:opener) { build_stubbed(:user) }
  let(:account) { build_stubbed(:account, opener: opener) }

  describe '#create?' do
    it 'returns true if user exists' do
      AccountPolicy.new(user, account).must_allow :create?
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
      user.stub(:approved_accounts, []) do
        AccountPolicy.new(user2, account).wont_allow :update?
      end
    end

    it 'returns true if user is a member of the account' do
      user.stub(:approved_accounts, [account]) do
        AccountPolicy.new(user, account).must_allow :update?
      end
    end
  end

  describe '#destroy?' do
    it 'returns true if user opened the account' do
      AccountPolicy.new(opener, account).must_allow :destroy?
    end

    it 'returns false if user did not open the account' do
      AccountPolicy.new(user, account).wont_allow :destroy?
    end
  end
end
