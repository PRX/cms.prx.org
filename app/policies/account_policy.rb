class AccountPolicy < ApplicationPolicy
  alias_method :account, :record

  def create?
    user.present?
  end

  def update?
    user && user.approved_accounts.include?(account)
  end

  def destroy?
    user && user.role_for(account) == 'admin'
  end
end
