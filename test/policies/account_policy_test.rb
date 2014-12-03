require 'test_helper'

describe AccountPolicy do
  let(:user) { build_stubbed(:user) }
  let(:user2) { build_stubbed(:user) }
  let(:account) { build_stubbed(:account) }

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
    it 'returns true if user is an admin' do
      user.stub(:role_for, 'admin') do
        AccountPolicy.new(user, account).must_allow :destroy?
      end
    end

    it 'returns false if user is not an admin' do
      user.stub(:role_for, nil) do
        AccountPolicy.new(user, account).wont_allow :destroy?
      end
    end
  end
end
