class StoryPolicy < AccountablePolicy
  def publish?
    update?
  end

  def unpublish?
    update?
  end
end
