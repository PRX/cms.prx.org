class AccountPolicy < ApplicationPolicy
  def create?
    token.present?
  end

  def update?
    token && token.authorized?(resource.id)
  end

  def destroy?
    token && token.authorized?(resource.id, :admin)
  end
end
