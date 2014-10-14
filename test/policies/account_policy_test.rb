require 'test_helper'

describe AccountPolicy do
  let(:user) { build_stubbed(:user) }
  let(:user2) { build_stubbed(:user) }
  let(:opener) { build_stubbed(:user) }
  let(:account) { build_stubbed(:account, opener: opener) }

  describe '#create?' do
    it 'returns true if user exists' do
      assert AccountPolicy.new(user, account).create?
    end

    it 'returns false if user is not present' do
      assert !AccountPolicy.new(nil, account).create?
    end
  end

  describe '#update?' do
    it 'returns false if user is not present' do
      assert !AccountPolicy.new(nil, account).update?
    end

    it 'returns false if user is not an approved member' do
      user.stub(:approved_accounts, []) do
        assert !AccountPolicy.new(user2, account).update?
      end
    end

    it 'returns true if user is a member of the account' do
      user.stub(:approved_accounts, [account]) do
        assert AccountPolicy.new(user, account).update?
      end
    end
  end

  describe '#destroy?' do
    it 'returns true if user opened the account' do
      assert AccountPolicy.new(opener, account).destroy?
    end

    it 'returns false if user did not open the account' do
      assert !AccountPolicy.new(user, account).destroy?
    end
  end
end
