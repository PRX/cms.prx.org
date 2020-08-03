class MembershipPolicy < ApplicationPolicy
  def create?
    update?
  end

  def update?
    token&.authorized?(resource.account.id, :account_members)
  end

  def destroy?
    update?
  end
end
