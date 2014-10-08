class ImagePolicy < ApplicationPolicy
  attr_reader :user, :image

  def initialize(user, image)
    @user = user
    @image = image
  end

  def update?
    policy_type.new(user, image_owner).update?
  end

  private

  def policy_type
    (image_owner_class + 'Policy').constantize
  end

  def image_owner_class
    image.class.name.split('Image')[0]
  end

  def image_owner
    image.send(image_owner_class.downcase)
  end
end
