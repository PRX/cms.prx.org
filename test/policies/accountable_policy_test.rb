require 'test_helper'

describe AccountablePolicy do
  let(:user) { build_stubbed(:user) }
  let(:mem) { build_stubbed(:membership, user: user) }
  let(:account) { mem.account }
  let(:story) { build_stubbed(:story, account: mem.account) }

  describe '#update?' do
    it 'returns false if user is not present' do
      AccountablePolicy.new(nil, story).wont_allow :update?
    end

    it 'returns false if user is not a member of the account' do
      user.stub(:approved_accounts, []) do
        AccountablePolicy.new(user, story).wont_allow :update?
      end
    end

    it 'returns true if is a member of the account' do
      user.stub(:approved_accounts, [account]) do
        AccountablePolicy.new(user, story).must_allow :update?
      end
    end
  end
end
