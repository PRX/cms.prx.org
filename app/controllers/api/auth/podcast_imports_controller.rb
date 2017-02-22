# encoding: utf-8

class Api::Auth::PodcastImportsController < Api::BaseController
  include ApiAuthenticated

  api_versions :v1

  filter_resources_by :account_id, :series_id

  filter_params :url

  def after_create_resource(res)
    res.import if res
  end

  def filtered(resources)
    resources = resources.find_by_url(filters.url) if filters.url?
    super
  end
end
