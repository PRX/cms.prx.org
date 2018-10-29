class AccountPolicy < ApplicationPolicy
  def create?
    token.present? && token.scopes&.include?('account:write')
  end

  def update?
    token && token.authorized?(resource.id)
  end

  def destroy?
    token && token.authorized?(resource.id, :admin)
  end
end
