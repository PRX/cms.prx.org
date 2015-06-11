class StoryAttributePolicy < ApplicationPolicy
  def create?
    update?
  end

  def update?
    AccountablePolicy.new(user, record.story).update?
  end
end
