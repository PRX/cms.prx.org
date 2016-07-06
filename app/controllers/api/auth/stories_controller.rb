# encoding: utf-8

class Api::Auth::StoriesController < Api::StoriesController

  include ApiAuthenticated

  api_versions :v1

  filter_resources_by :account_id, :series_id

  announce_actions :create, :update, :delete, :publish, :unpublish

  represent_with Api::Auth::StoryRepresenter

  def sorted(res)
    res.order('updated_at desc')
  end

  # ALL stories - not just published and visible
  def scoped(relation)
    relation
  end

  def filtered(resources)
    if filters.include?('noseries')
      resources.unseries
    else
      super
    end
  end

  def resources_base
    @stories ||= current_user.approved_account_stories
  end

  def filters
    @filters ||= (params[:filters] || '').split(',')
  end

end
