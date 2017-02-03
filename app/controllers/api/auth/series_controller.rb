# encoding: utf-8

class Api::Auth::SeriesController < Api::SeriesController
  include ApiAuthenticated

  api_versions :v1

  filter_resources_by :account_id

  represent_with Api::Auth::SeriesRepresenter

  def resources_base
    @series ||= authorization.token_auth_series
  end
end
