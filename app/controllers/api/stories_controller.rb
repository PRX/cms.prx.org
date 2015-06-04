# encoding: utf-8

class Api::StoriesController < Api::BaseController

  api_versions :v1

  filter_resources_by :series_id, :account_id

  announce_actions :create, :update, :delete, :publish, :unpublish

  def publish
    publish_resource.tap do |res|
      authorize res
      res.publish!
      respond_with root_resource(res), show_options
    end
  end

  def publish_resource
    @story ||= Story.unpublished.where(id: params[:id]).first
  end

  def unpublish
    unpublish_resource.tap do |res|
      authorize res
      res.unpublish!
      respond_with root_resource(res), show_options
    end
  end

  def unpublish_resource
    @story ||= Story.published.where(id: params[:id]).first
  end

  def random
    @story = Story.published.limit(1).order('RAND()').first
    show
  end

  private

  def resources_base
    if highlighted?
      account.portfolio_stories
    else
      super
    end
  end

  def filtered(resources)
    if highlighted?
      resources
    else
      super
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

  def sorted(res)
    if filters.include?('purchased')
      res.purchased.order('purchase_count DESC')
    else
      res.order('published_at desc')
    end
  end

  def filters
    @filters ||= (params[:filters] || '').split(',')
  end

  def highlighted?
    account && filters.include?('highlighted')
  end

  def account
    @account ||= Account.find(params[:account_id]) if params[:account_id]
  end
end
