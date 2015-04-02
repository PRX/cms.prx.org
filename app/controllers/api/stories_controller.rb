# encoding: utf-8

class Api::StoriesController < Api::BaseController

  api_versions :v1

  filter_resources_by :series_id, :account_id

  def random
    @story = Story.published.limit(1).order('RAND()').first
    show
  end

  def resource
    @story ||= if params[:id]
      Story.published.visible.find_by_id(params[:id])
    else
      Story.new
    end
  end

  def resources
    @stories ||= resources_base.includes(
      { audio_versions: [:audio_files] },
      { account: [:image, :address, { opener: [:image] }] },
      { series: [:image, :account] },
      :images,
      :license
    )
  end

  def resources_base
    stories = nil
    filters = params[:filters].try(:split, ',') || []

    stories = if account && filters.include?('highlighted')
                account.portfolio_stories
              elsif account
                account.stories
              else
                Story
              end

    if filters.include?('purchased')
      stories = stories.purchased.order('purchase_count DESC')
    else
      stories = stories.order('published_at desc')
    end

    stories.published.visible
  end

  def account
    @account ||= Account.find(params[:account_id]) if params[:account_id]
  end

  # don't add another order, handled in the resources_base
  def with_ordering(res)
    res
  end
end
