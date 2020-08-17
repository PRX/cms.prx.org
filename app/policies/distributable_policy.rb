class DistributablePolicy < ApplicationPolicy
  def initialize(token, resource)
    super
    sub_policy_class = resource && Pundit::PolicyFinder.new(resource.distributable.class).policy!
    @sub_policy = sub_policy_class.new(token, resource.distributable)
  end

  def create?
    @sub_policy&.create?
  end

  def update?
    @sub_policy&.update?
  end
end
