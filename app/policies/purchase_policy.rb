class PurchasePolicy < ApplicationPolicy
  def create?
    token&.authorized?(resource.purchaser_account.id, :purchase)
  end

  def update?
    false
  end

  def destroy?
    false
  end
end
