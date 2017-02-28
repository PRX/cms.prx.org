# encoding: utf-8

class Api::SeriesImagesController < Api::BaseController
  api_versions :v1

  filter_resources_by :series_id

  announce_actions decorator: Api::Msg::ImageRepresenter, subject: :image
  announce_actions :update, resource: :series_resource

  represent_with Api::ImageRepresenter

  def series_resource
    resource.try(:series)
  end
end
