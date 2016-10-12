# encoding: utf-8

class Api::SeriesImagesController < Api::BaseController
  include Announce::Publisher

  api_versions :v1

  filter_resources_by :series_id

  announce_actions decorator: Api::Msg::ImageRepresenter, subject: :image

  represent_with Api::ImageRepresenter

  child_resource parent: 'series', child: 'image'

  def after_original_destroyed(original)
    announce('image', 'destroy', Api::Msg::ImageRepresenter.new(original).to_json)
  end
end
