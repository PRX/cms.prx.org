class MembershipPolicy < ApplicationPolicy
  attr_reader :user, :membership

  def initialize(user, membership)
    @user = user
    @membership = membership
  end

  def create?
    true
  end

  def update?
  end

  def destroy?
    user == membership.user
  end
end
