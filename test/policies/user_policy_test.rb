require 'test_helper'

describe UserPolicy do
  let(:user1) { build_stubbed(:user) }
  let(:user2) { build_stubbed(:user) }

  describe '#update?' do
    it 'lets users update themselves' do
      UserPolicy.new(user1, user1).must_allow :update?
    end

    it 'does not let users update each other' do
      UserPolicy.new(user1, user2).wont_allow :update?
    end
  end
end
