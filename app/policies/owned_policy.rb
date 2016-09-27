class OwnedPolicy < ApplicationPolicy
  def create?
    update?
  end

  def update?
    return false if resource.owner.nil?
    policy_type = Pundit::PolicyFinder.new(resource.owner.class).policy!
    policy_type.new(token, resource.owner).update?
  end
end
