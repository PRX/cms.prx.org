require 'test_helper'

describe UserTagPolicy do
  let(:user_tag) { create(:user_tag) }
  let(:account) { create(:account) }
  let(:token) { StubToken.new(account.id, ['cms:account']) }

  it 'allows anyone to create a tag' do
    UserTagPolicy.new(token, UserTag.new(name: 'test-tag')).must_allow :create?
  end

  it 'prevents anyone from updating a tag' do
    UserTagPolicy.new(token, user_tag).wont_allow :update?
  end

  it 'prevents anyone from destroying a tag' do
    UserTagPolicy.new(token, user_tag).wont_allow :destroy?
  end
end
