# encoding: utf-8

class Api::Auth::EpisodeImportsController < Api::BaseController
  include ApiAuthenticated

  api_versions :v1

  filter_resources_by :podcast_import_id

  filter_params :guid

  represent_with Api::EpisodeImportRepresenter

  def retry
    update_resource.tap do |res|
      authorize res
      res.retry!
      respond_with root_resource(res), update_resource
    end
  end

  def after_create_resource(res)
    res.try(:import_later)
  end

  def filtered(resources)
    resources = resources.find_by_guid(filters.guid) if filters.guid?
    super
  end
end
