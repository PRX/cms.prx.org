# encoding: utf-8

class Api::AudioVersionTemplatesController < Api::BaseController
  api_versions :v1

  filter_resources_by :series_id, :distribution_id

  sort_params default: { label: :asc }, allowed: [:id, :label]

  def filtered(arel)
    if params['distribution_id']
      distribution_id = params.delete('distribution_id')
      arel = arel.joins(:distribution_templates).where('distribution_templates.distribution_id = ?', distribution_id)
    end
    super(arel)
  end
end
