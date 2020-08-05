class AccountablePolicy < ApplicationPolicy
  def initialize(token, resource, scope = :account)
    super(token, resource)
    @scope = scope
  end

  def create?
    update?
  end

  def update?
    token&.authorized?(resource.account.id, @scope)
  end

  def destroy?
    update?
  end
end
