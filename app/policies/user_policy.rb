class UserPolicy < ApplicationPolicy
  def create?
    false
  end

  def update?
    token.user_id == resource.id
  end
end
