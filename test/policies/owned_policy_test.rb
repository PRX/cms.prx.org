require 'test_helper'

class OwnedTestModel
  attr_accessor :owner
end

describe OwnedPolicy do
  let(:account) { create(:account) }
  let(:owned) { OwnedTestModel.new.tap { |o| o.owner = account } }
  let(:token) { StubToken.new(account.id, ['account']) }
  let(:bad_token) { StubToken.new(account.id + 1, ['account']) }

  describe '#update? or #create?' do
    it 'returns true if authorized on owning account' do
      OwnedPolicy.new(token, owned).must_allow :update?
      OwnedPolicy.new(token, owned).must_allow :create?
    end

    it 'returns false if authorized on non-owning account' do
      OwnedPolicy.new(bad_token, owned).wont_allow :update?
      OwnedPolicy.new(bad_token, owned).wont_allow :create?
    end

    it 'returns false if there is no owner' do
      owned.owner = nil
      OwnedPolicy.new(token, owned).wont_allow :update?
      OwnedPolicy.new(token, owned).wont_allow :create?
    end
  end
end
