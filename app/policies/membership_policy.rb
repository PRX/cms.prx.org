class MembershipPolicy < ApplicationPolicy
  attr_reader :user, :membership

  def initialize(user, membership)
    @user = user
    @membership = membership
  end

  def create?
    update? || (user == membership.user && !membership.approved?)
  end

  def update?
    user && user.role_for(membership.account) == 'admin'
  end

  def destroy?
    user == membership.user || user.role_for(membership.account) == 'admin'
  end
end
