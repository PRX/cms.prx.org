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
    user && user.role_for(membership.account) == 'admin'
  end

  def destroy?
    user == membership.user || user.role_for(membership.account) == 'admin'
  end
end
