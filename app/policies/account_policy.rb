class AccountPolicy < ApplicationPolicy
  def create?
    token.present?
  end

  def update?
    token&.authorized?(resource.id, :account)
  end

  def destroy?
    token&.authorized?(resource.id, :account_members)
  end
end
