class StoryPolicy < ApplicationPolicy

  def create?
    authorized?(:story) || (resource.draft? && authorized?(:story_draft))
  end

  def update?
    authorized?(:story) || (authorized?(:story_draft) && resource.draft? && resource.was_draft?)
  end

  def destroy?
    update?
  end

  def publish?
    authorized?(:story)
  end

  def unpublish?
    publish?
  end
end
