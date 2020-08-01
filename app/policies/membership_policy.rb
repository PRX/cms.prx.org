class MembershipPolicy < ApplicationPolicy
  def create?
    update? || (token.user_id == resource.user.id && !resource.approved?)
  end

  def update?
    token&.authorized?(resource.account.id, :account_members)
  end

  def destroy?
    token.user_id == resource.user.id || update?
  end
end
