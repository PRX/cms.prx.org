# encoding: utf-8

class Api::Auth::StoriesController < Api::StoriesController

  include ApiAuthenticated

  api_versions :v1

  filter_resources_by :account_id, :series_id

  filter_params :noseries

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
    if filters.noseries?
      resources.unseries
    else
      super
    end
  end

  def resources_base
    @stories ||= current_user.approved_account_stories
  end

  def create_resource
    super.tap do |story|
      story.creator_id = current_user.id
      story.account_id ||= story.series.try(:account_id)
      story.account_id ||= current_user.account_id
      story.account_id ||= current_user.approved_accounts.first.try(:id)
    end
  end

end
