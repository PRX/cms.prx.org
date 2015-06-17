class UserPolicy < ApplicationPolicy
  def create?
    true
  end

  def update?
    token.user_id == resource.id
  end
end
