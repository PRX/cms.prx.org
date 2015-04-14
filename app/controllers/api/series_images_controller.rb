# encoding: utf-8

class Api::SeriesImagesController < Api::BaseController

  api_versions :v1

  filter_resources_by :series_id

  represent_with Api::ImageRepresenter
end
