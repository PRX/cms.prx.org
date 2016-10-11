# encoding: utf-8

class Api::AccountImagesController < Api::BaseController
  include Announce::Publisher

  api_versions :v1

  filter_resources_by :account_id

  announce_actions decorator: Api::Msg::ImageRepresenter, subject: :image

  represent_with Api::ImageRepresenter

  child_resource parent: 'account', child: 'image'

  def after_original_destroyed(original)
    announce('image', 'destroy', Api::Msg::ImageRepresenter.new(original).to_json)
  end
end
