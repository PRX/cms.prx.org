class UserPolicy < ApplicationPolicy
  alias_method :other_user, :record

  def create?
    true
  end

  def update?
    user == other_user
  end
end
