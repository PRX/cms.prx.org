require 'test_helper'

describe ImagePolicy do
  let(:account) { build_stubbed(:account) }
  let(:series_member_token) { StubToken.new(account.id, ['cms:series']) }
  let(:account_member_token) { StubToken.new(account.id, ['cms:account']) }

  describe 'series images' do
    let(:series) { build_stubbed(:series, account: account) }
    let(:series_image) { build_stubbed(:series_image, series: series) }

    it 'returns true if user is a member of account' do
      ImagePolicy.new(series_member_token, series_image).must_allow :update?
    end

    it 'returns false if user is not a member' do
      ImagePolicy.new(account_member_token, series_image).wont_allow :update?
    end
  end

  describe 'user images' do
    let(:user_image) { build_stubbed(:user_image, user: User.new(id: series_member_token.user_id)) }

    it 'returns false if users are the same' do
      ImagePolicy.new(series_member_token, user_image).wont_allow :update?
    end

    it 'returns false if users are different' do
      ImagePolicy.new(account_member_token, user_image).wont_allow :update?
    end
  end
end
