# encoding: utf-8

class Api::SeriesController < Api::BaseController
  api_versions :v1

  filter_resources_by :account_id

  filter_params :v4

  sort_params default: { updated_at: :desc },
              allowed: [:id, :created_at, :updated_at, :title]

  def filtered(resources)
    resources = resources.v4 if filters.v4?
    super
  end
end
