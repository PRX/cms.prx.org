class AccountablePolicy < ApplicationPolicy
  def initialize(token, resource, scopes = :account)
    super(token, resource)
    @scopes = Array.wrap(scopes)
  end

  def create?
    update?
  end

  def update?
    @scopes.all? { |scope| authorized?(scope) }
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
    super
  end
end
