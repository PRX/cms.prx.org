# encoding: utf-8

class Api::DistributionsController < Api::BaseController
  api_versions :v1

  filter_resources_by :series_id

  represent_with Api::DistributionRepresenter

  def filtered(arel)
    polymorphic_filtered('distributable', arel)
  end
end
