class Api::BaseImagesController < Api::BaseController
  include Announce::Publisher

  announce_actions decorator: Api::Msg::ImageRepresenter, subject: :image

  def after_create_resource(image)
    super
    image.copy_upload!
  end

  def after_update_resource(image)
    super
    image.copy_upload!
  end

  def after_destroy_resource(image)
    super
    image.remove!
  end

end
