class PurchasePolicy < ApplicationPolicy
  def create?
    token && token.authorized?(resource.purchaser_account.id, :admin)
  end

  def update?
    false
  end

  def destroy?
    false
  end
end
