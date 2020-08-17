class AccountablePolicy < ApplicationPolicy
  def initialize(token, resource, scope = :account)
    super(token, resource)
    @scope = scope
  end

  def create?
    update?
  end

  def update?
    authorized?(@scope)
  end

  def destroy?
    update?
  end

  private

  def resource_id
    resource&.account&.id
  end

  def resource_id_was
    resource&.account_was&.id
  rescue StandardError
    nil
  end
end
