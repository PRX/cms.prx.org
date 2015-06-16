class AccountablePolicy < ApplicationPolicy
  def create?
    update?
  end

  def update?
    token && token.authorized?(resource.account.id)
  end

  def destroy?
    update?
  end
end
