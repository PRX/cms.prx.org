class SeriesAttributePolicy < ApplicationPolicy
  def create?
    update?
  end

  def update?
    AccountablePolicy.new(token, resource.series, :series).update?
  end
end
