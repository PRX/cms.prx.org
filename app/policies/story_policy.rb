class StoryPolicy < ApplicationPolicy

  def create?
    token&.authorized?(resource.account_id, :story) ||
      (resource.draft? && token&.authorized?(resource.account_id, :story_draft))
  end

  def update?
    token&.authorized?(resource.account_id, :story) ||
      (token&.authorized?(resource.account_id, :story_draft) && resource.draft? &&  resource.was_draft?)
  end

  def destroy?
    update?
  end

  def publish?
    token&.authorized?(resource.account_id, :story)
  end

  def unpublish?
    publish?
  end
end
