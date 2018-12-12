require 'test_helper'

describe IndividualAccountPolicy do
  let(:existing_user) { create(:user, with_individual_account: true) }
  let(:existing_token) { StubToken.new(nil, nil, existing_user.id) }
  let(:new_user) { create(:user, with_individual_account: false) }
  let(:new_token) { StubToken.new(nil, nil, new_user.id) }
  let(:account) { build_stubbed(:account) }

  describe '#create?' do
    it 'returns true for user without individual account' do
      IndividualAccountPolicy.new(new_token, account).must_allow :create?
    end
    it 'returns false for user with individual account' do
      IndividualAccountPolicy.new(existing_token, account).wont_allow :create?
    end
  end
end
