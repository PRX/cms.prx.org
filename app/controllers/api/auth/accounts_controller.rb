# encoding: utf-8

class Api::Auth::AccountsController < Api::AccountsController
  include ApiAuthenticated

  api_versions :v1

  represent_with Api::Auth::AccountRepresenter

  filter_resources_by :user_id

  before_filter :ensure_write_scope, except: [:index, :show]

  def create_resource
    return super unless params['user_id']

    account_user = User.find(params['user_id'])
    account_user.create_individual_account
    account_user.individual_account
  end

  private

  def ensure_write_scope
    user_not_authorized unless prx_auth_token.scopes&.include? 'account:write'
  end

  def resources
    self.resources = decorate_query(resources_base)
  end

  def resources_base
    authorization.token_auth_accounts
  end
end
