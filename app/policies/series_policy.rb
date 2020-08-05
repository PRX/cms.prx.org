class SeriesPolicy < ApplicationPolicy
  def create?
    update?
  end

  def update?
    AccountablePolicy.new(token, resource, :series).update?
  end
end
