# encoding: utf-8

class Api::SeriesController < Api::BaseController

  api_versions :v1

  filter_resources_by :account_id

  filter_params :v4, :text

  def filtered(resources)
    resources = resources.v4 if filters.v4?
    resources = resources.match_text(filters.text) if filters.text?
    super
  end
end
