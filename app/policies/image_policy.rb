class ImagePolicy < ApplicationPolicy
  def create?
    update?
  end

  def update?
    policy_type.new(token, image_owner).update?
  end

  private

  def policy_type
    Pundit::PolicyFinder.new(image_owner_class.constantize).policy!
  end

  def image_owner_class
    resource.class.name.split('Image')[0]
  end

  def image_owner
    resource.send(image_owner_class.downcase)
  end
end
