class StoryPolicy < AccountablePolicy
  def initialize(token, resource)
    super(token, resource, :story)
  end
  
  def publish?
    update?
  end

  def unpublish?
    update?
  end
end
