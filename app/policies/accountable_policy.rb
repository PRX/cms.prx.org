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
    resource.try(:account).try(:id) || resource.try(:account_id)
  end

  def resource_id_was
    resource.try(:account_was).try(:id) || resource.try(:account_id_was)
  end
end
