# encoding: utf-8

class Api::Auth::SeriesController < Api::SeriesController
  include ApiAuthenticated

  api_versions :v1

  filter_resources_by :account_id

  represent_with Api::Auth::SeriesRepresenter

  def resources_base
    @series ||= current_user.approved_account_series
  end
end
