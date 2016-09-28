# encoding: utf-8

class Api::AudioVersionTemplatesController < Api::BaseController
  api_versions :v1

  filter_resources_by :series_id

  sort_params default: { label: :asc }, allowed: [:id, :label]
end
