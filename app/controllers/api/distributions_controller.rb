# encoding: utf-8

require 'abstract_resource'
require 'api/distribution_representer'
require 'api/distributions/podcast_distribution_representer'

class Api::DistributionsController < Api::BaseController
  include AbstractResource

  api_versions :v1

  filter_resources_by :series_id

  announce_actions resource: :owner_resource, action: :update

  around_action :wrap_in_transaction, only: :create

  def owner_resource
    resource.try(:owner)
  end

  def after_create_resource(res)
    res.distribute! if res
  end

  def filtered(arel)
    polymorphic_filtered('distributable', arel)
  end
end
