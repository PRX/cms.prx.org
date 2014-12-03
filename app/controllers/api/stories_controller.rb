# encoding: utf-8

class Api::StoriesController < Api::BaseController

  api_versions :v1

  filter_resources_by :series_id, :account_id

  def resource
    @story ||= Story.published.visible.find_by_id(params[:id])
  end

  def resources
    @stories ||=  resources_base.includes({audio_versions: [:audio_files]}, {account: [:image, :address, {opener:[:image]}]}, {series:[:image, :account]}, :images, :license)
  end

  def resources_base
    filters = params[:filters].try(:split, ',') || []

    if params[:account_id].present? && filters.include?('highlighted')
      stories = Account.find(params[:account_id]).portfolio_stories
    else
      stories = Story
    end

    if filters.include?('purchased')
      stories = stories.purchased.order('purchase_count DESC')
    else
      stories = stories.order('published_at desc')
    end

    stories.published.visible.page(params[:page])
  end

end
