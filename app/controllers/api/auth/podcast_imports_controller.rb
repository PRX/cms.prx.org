# encoding: utf-8

class Api::Auth::PodcastImportsController < Api::BaseController
  include ApiAuthenticated

  api_versions :v1

  filter_resources_by :account_id, :series_id

  filter_params :url

  represent_with Api::PodcastImportRepresenter

  def retry
    update_resource.tap do |res|
      authorize res
      res.retry!
      respond_with root_resource(res), update_resource
    end
  end

  def create_resource
    super.tap do |podcast_import|
      podcast_import.user_id ||= current_user.id
      podcast_import.account_id ||= (params[:account_id] || params[:accountId] || current_user.account_id)
    end
  end

  def after_create_resource(res)
    res.try(:import_later)
  end

  def filtered(resources)
    resources = resources.find_by_url(filters.url) if filters.url?
    super
  end
end
