# encoding: utf-8

class Api::StoriesController < Api::BaseController

  api_versions :v1

  filter_resources_by :series_id, :account_id

  after_action :announce_story_update, only: [:create, :update], if: ->() { response.successful? }
  after_action :announce_story_delete, only: [:destroy], if: ->() { response.successful? }

  def announce_story_update
    representer = Api::Min::StoryRepresenter.new(resource)
    announce(:story, :update, representer.to_json)
  end

  def announce_story_delete
    representer = Api::Min::StoryRepresenter.new(resource)
    announce(:story, :delete, representer.to_json)
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
