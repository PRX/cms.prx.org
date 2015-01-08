require 'test_helper'

describe ApplicationPolicy do
  let(:user) { "user" }
  let(:record) { "record" }

  it 'prevents create' do
    ApplicationPolicy.new(user, record).wont_allow :create?
  end

  it 'prevents update' do
    ApplicationPolicy.new(user, record).wont_allow :update?
  end

  it 'prevents destroy' do
    ApplicationPolicy.new(user, record).wont_allow :destroy?
  end
end
