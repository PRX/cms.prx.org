require 'test_helper'

describe UserPolicy do
  let(:user_token) { StubToken.new(123, ['member']) }
  let(:other_token) { StubToken.new(123, ['member']) }
  let(:user) { build_stubbed(:user, id: user_token.user_id) }

  describe '#update?' do
    it 'lets users update themselves' do
      UserPolicy.new(user_token, user).must_allow :update?
    end

    it 'does not let users update each other' do
      UserPolicy.new(other_token, user).wont_allow :update?
    end
  end

  describe '#create?' do
    it 'never allows create' do
      UserPolicy.new(user_token, user).wont_allow :create?
      UserPolicy.new(other_token, user).wont_allow :create?
    end
  end
end
