class StoryAttributePolicy < ApplicationPolicy
  def create?
    update?
  end

  def update?
    AccountablePolicy.new(token, resource.story, :story).update?
  end
end
