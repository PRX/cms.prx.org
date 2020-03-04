# encoding: utf-8

class Api::SeriesImagesController < Api::BaseImagesController
  api_versions :v1
  represent_with Api::ImageRepresenter

  filter_resources_by :series_id

  announce_actions :update, resource: :series_resource

  def series_resource
    resource.try(:series)
  end
end
