class UserPolicy < ApplicationPolicy
  def create?
    false
  end

  def update?
    false
  end
end
