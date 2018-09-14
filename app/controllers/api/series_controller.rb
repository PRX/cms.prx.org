# encoding: utf-8

class Api::SeriesController < Api::BaseController
  include ApiSearchable

  api_versions :v1

  filter_resources_by :account_id

  filter_params :v4, :text

  sort_params default: { updated_at: :desc },
              allowed: [:id, :created_at, :updated_at, :title]

  announce_actions

  def search
    @series ||= Series.text_search(search_query, search_params)
    index
  end

  def search_params
    sparams = super
    sparams[:sort] = rename_sort_param(sparams[:sort], 'title', 'title.keyword')
    sparams[:fq]['account_id'] = params[:account_id] if params[:account_id]
    sparams[:fq]['app_version'] = 'v4' if filters.v4?
    sparams
  end

  def filtered(resources)
    resources = resources.v4 if filters.v4?
    resources = resources.match_text(filters.text) if filters.text?
    super
  end

  def create_resource
    super.tap do |series|
      if account && authorization.authorized?(account)
        series.account_id ||= account.id
      end

      if authorization.authorized?(current_user.default_account)
        series.account_id ||= current_user.account_id
      end

      series.account_id ||= authorization.token_auth_accounts.first.try(:id)
    end
  end

  def create
    # XXX this method is copied from the ResourceCallbacks concern
    json_body_params = JSON.parse(request.body)

    series = create_resource
    consume! series, create_options
    hal_authorize series

    @series = if json_body_params.has_key?('import_url')
                Series.create_from_feed(json_body_params['import_url'],
                                        current_user,
                                        account)
              else
                series.save!
                series
              end
    after_create_resource(@series)
    respond_with root_resource(@series), create_options
  end

  def included(relation)
    relation.includes(
      { account: [:image, :address, { opener: [:image] }] },
      :images,
      :distributions
    )
  end

  def account
    @account ||= Account.find(params[:account_id]) if params[:account_id]
  end
end
