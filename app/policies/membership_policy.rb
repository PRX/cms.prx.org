class MembershipPolicy < ApplicationPolicy
  alias_method :membership, :record

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
