class ImagePolicy
  attr_reader :user, :image

  def initialize(user, image)
    @user = user
    @image = image
  end

  def create?
    update?
  end

  def update?
    policy_type.new(user, image_owner).update?
  end

  private

  def policy_type
    Pundit::PolicyFinder.new(image_owner_class.constantize).policy!
  end

  def image_owner_class
    image.class.name.split('Image')[0]
  end

  def image_owner
    image.send(image_owner_class.downcase)
  end
end
