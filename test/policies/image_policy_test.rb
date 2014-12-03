require 'test_helper'

describe ImagePolicy do
  let(:user) { build_stubbed(:user) }

  describe 'series images' do
    let(:account) { build_stubbed(:account) }
    let(:series) { build_stubbed(:series, account: account) }
    let(:series_image) { build_stubbed(:series_image, series: series) }

    it 'returns true if user is a member of account' do
      user.stub(:approved_accounts, [account]) do
        ImagePolicy.new(user, series_image).must_allow :update?
      end
    end

    it 'returns false if user is not a member' do
      user.stub(:approved_accounts, []) do
        ImagePolicy.new(user, series_image).wont_allow :update?
      end
    end
  end

  describe 'user images' do
    let(:user_image) { build_stubbed(:user_image, user: user) }
    let(:user2) { build_stubbed(:user) }

    it 'returns true if users are the same' do
      ImagePolicy.new(user, user_image).must_allow :update?
    end

    it 'returns false if users are different' do
      ImagePolicy.new(user2, user_image).wont_allow :update?
    end
  end
end
