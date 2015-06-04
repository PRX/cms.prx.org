class AccountablePolicy < ApplicationPolicy
  def create?
    update?
  end

  def update?
    user && user.approved_accounts.include?(record.account)
  end

  def destroy?
    update?
  end
end
