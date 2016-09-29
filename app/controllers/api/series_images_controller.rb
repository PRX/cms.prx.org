# encoding: utf-8

class Api::SeriesImagesController < Api::BaseController
  api_versions :v1

  filter_resources_by :series_id

  announce_actions decorator: Api::Msg::ImageRepresenter, subject: :image

  represent_with Api::ImageRepresenter

  def resource
    @series_image ||= series.try(:image) || super
  end

  def series
    @series ||= Series.find(params[:series_id]) if params[:series_id]
  end
end
