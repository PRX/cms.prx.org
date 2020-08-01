class AccountPolicy < ApplicationPolicy
  def create?
    token.present?
  end

  def update?
    token && token.authorized?(resource.id, :account)
  end

  def destroy?
    token && token.authorized?(resource.id, :account_members)
  end
end
