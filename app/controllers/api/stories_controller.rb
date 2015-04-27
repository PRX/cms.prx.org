# encoding: utf-8

class Api::StoriesController < Api::BaseController

  api_versions :v1

  filter_resources_by :series_id, :account_id

  def random
    @story = Story.published.limit(1).order('RAND()').first
    show
  end

  def resources_base
    stories = nil
    filters = (params[:filters] || '').split(',')

    stories = if account && filters.include?('highlighted')
                account.portfolio_stories
              elsif account
                account.stories
              else
                Story
              end

    if filters.include?('purchased')
      stories.purchased.order('purchase_count DESC')
    else
      stories.order('published_at desc')
    end
  end

  def included(relation)
    relation.includes(
      { audio_versions: [:audio_files] },
      { account: [:image, :address, { opener: [:image] }] },
      { series: [:image, :account] },
      :images,
      :license
    )
  end

  def scoped(relation)
    relation.published.visible
  end

  # don't add another order, handled in the resources_base
  def sorted(res)
    res
  end

  def account
    @account ||= Account.find(params[:account_id]) if params[:account_id]
  end
end
