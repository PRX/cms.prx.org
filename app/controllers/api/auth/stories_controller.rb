# encoding: utf-8

class Api::Auth::StoriesController < Api::StoriesController
  include ApiAuthenticated
  include ApiSearchable

  api_versions :v1

  filter_resources_by :account_id, :series_id, :network_id

  filter_params :highlighted, :purchased, :v4, :text, :noseries, :state,
                before: :time, after: :time

  sort_params default: { updated_at: :desc },
              allowed: [:id, :created_at, :updated_at, :published_at, :title,
                        :episode_number, :position, :published_released_at]

  announce_actions :create, :update, :destroy, :publish, :unpublish

  represent_with Api::Auth::StoryRepresenter

  before_filter :check_user_network, only: [:index], if: -> { params[:network_id] }

  def sorted(arel)
    if coalesce_sort = (sorts || []).find_index { |s| s.keys.first == 'published_released_at' }
      arel = arel.coalesce_published_released(sorts[coalesce_sort].values.first)
      sorts.delete_at(coalesce_sort)
    end
    if pub_sort = (sorts || []).find_index { |s| s.keys.first == 'published_at' }
      sorts.insert(pub_sort, 'ISNULL(`pieces`.`published_at`) DESC')
    end
    super
  end

  def check_user_network
    user_not_authorized unless current_user.networks.exists?(params[:network_id])
  end

  # ALL stories - not just published and visible
  def scoped(relation)
    relation
  end

  def filtered(resources)
    resources = resources.unseries if filters.noseries?
    resources = filter_by_state(resources, filters.state) if filters.state?
    super(resources)
  end

  def filter_by_state(resources, state)
    if state == 'published'
      resources.published
    elsif state == 'unpublished'
      resources.unpublished
    elsif state == 'scheduled'
      resources.scheduled
    elsif state == 'draft'
      resources.draft
    else
      raise ApiFiltering::BadFilterValueError.new("Invalid state filter: #{state}")
    end
  end

  def resources_base
    # If there is a network_id specified, use that network.
    # The authz is performed in check_user_network().
    @stories ||= if params[:network_id]
      super.published
    else
      authorization.token_auth_stories
    end
  end

  def search
    # same logic as resources_base above
    @stories ||= if params[:network_id]
      Story.text_search(search_query, search_params)
    else
      Story.text_search(search_query, search_params, authorization)
    end
    index
  end

  def search_params
    sparams = super
    sparams[:fq]['series_id'] = 'NULL' if filters.noseries?
    sparams[:state] = search_by_state(filters.state) if filters.state?
    sparams
  end

  def search_by_state(state)
    if %w(published unpublished scheduled draft).include?(state)
      state
    else
      raise ApiFiltering::BadFilterValueError.new("Invalid state filter: #{state}")
    end
  end
end
