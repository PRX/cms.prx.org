# encoding: utf-8

class Api::DistributionsController < Api::BaseController
  api_versions :v1

  filter_resources_by :series_id

  announce_actions resource: :owner_resource

  def owner_resource
    resource.try(:owner)
  end

  def filtered(arel)
    polymorphic_filtered('distributable', arel)
  end
end
