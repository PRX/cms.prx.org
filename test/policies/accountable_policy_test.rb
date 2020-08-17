require 'test_helper'

describe AccountablePolicy do
  let(:non_member_token) { StubToken.new(account.id + 1, ['cms:account']) }
  let(:member_token) { StubToken.new(account.id, ['cms:account']) }
  let(:account) { create(:account) }
  let(:playlist) { create(:playlist, account: account) }
  let(:playlist_section) { create(:playlist_section, playlist: playlist) }
  let(:pick) { create(:pick, playlist_section: playlist_section) }

  describe '#update?' do
    it 'returns false if user is not present' do
      AccountablePolicy.new(nil, pick).wont_allow :update?
    end

    it 'returns false if user is not a member of the account' do
      AccountablePolicy.new(non_member_token, pick).wont_allow :update?
    end

    it 'returns true if is a member of the account' do
      AccountablePolicy.new(member_token, pick).must_allow :update?
    end

    describe 'with a scope specified' do
      it 'returns true if the scope is present in the token for the given account-owned object' do
        AccountablePolicy.new(member_token, pick, :account).must_allow :update?
      end

      it 'returns false if the scope is missing in the token for the given account-owned object' do
        AccountablePolicy.new(member_token, pick, :admin).wont_allow :update?
      end
    end
  end
end
