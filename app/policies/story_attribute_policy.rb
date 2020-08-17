class StoryAttributePolicy < StoryPolicy
  def initialize(token, resource)
    super(token, resource.story)
  end
end
