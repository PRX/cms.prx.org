# encoding: utf-8

class Api::SeriesController < Api::BaseController
  api_versions :v1

  filter_resources_by :account_id

  filter_params :v4, :text

  sort_params default: { updated_at: :desc },
              allowed: [:id, :created_at, :updated_at, :title]

  announce_actions

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

  def account
    @account ||= Account.find(params[:account_id]) if params[:account_id]
  end
end
