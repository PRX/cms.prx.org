# encoding: utf-8

class Api::AccountImagesController < Api::BaseImagesController
  api_versions :v1
  represent_with Api::ImageRepresenter

  filter_resources_by :account_id

  child_resource parent: 'account', child: 'image'

  def after_original_destroyed(original)
    announce('image', 'destroy', Api::Msg::ImageRepresenter.new(original).to_json)
  end

end
