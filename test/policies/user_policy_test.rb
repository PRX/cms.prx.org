require 'test_helper'

describe UserPolicy do
  let(:user1) { build_stubbed(:user) }
  let(:user2) { build_stubbed(:user) }

  describe '#update?' do
    it 'lets users update themselves' do
      assert UserPolicy.new(user1, user1).update?
    end

    it 'does not let users update each other' do
      assert !UserPolicy.new(user1, user2).update?
    end
  end
end
