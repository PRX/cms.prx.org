# encoding: utf-8

class Api::UserImagesController < Api::BaseImagesController
  include Announce::Publisher

  api_versions :v1
  represent_with Api::ImageRepresenter

  filter_resources_by :user_id

  child_resource parent: 'user', child: 'image'

  def after_original_destroyed(original)
    announce('image', 'destroy', Api::Msg::ImageRepresenter.new(original).to_json)
    original.remove!
  end
end
