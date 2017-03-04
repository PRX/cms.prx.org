require 'test_helper'

describe AccountablePolicy do
  let(:non_member_token) { StubToken.new(account.id + 1, ['no']) }
  let(:member_token) { StubToken.new(account.id, ['member']) }
  let(:account) { build_stubbed(:account) }
  let(:story) { build(:story, account: account)}

  describe '#update?' do
    it 'returns false if user is not present' do
      AccountablePolicy.new(nil, story).wont_allow :update?
    end

    it 'returns false if user is not a member of the account' do
      AccountablePolicy.new(non_member_token, story).wont_allow :update?
    end

    it 'returns true if is a member of the account' do
      AccountablePolicy.new(member_token, story).must_allow :update?
    end
  end
end
