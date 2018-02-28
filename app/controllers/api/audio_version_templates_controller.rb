# encoding: utf-8

class Api::AudioVersionTemplatesController < Api::BaseController
  api_versions :v1

  filter_resources_by :series_id, :distribution_id

  sort_params default: { label: :asc }, allowed: %i[id label]

  attr_accessor :distribution_id

  def filtered(arel)
    self.distribution_id = params.delete(:distribution_id).to_i if params[:distribution_id]

    if distribution_id
      arel = arel.joins(:distribution_templates)
      arel = arel.where('distribution_templates.distribution_id = ?', distribution_id)
    end

    super(arel)
  end
end
