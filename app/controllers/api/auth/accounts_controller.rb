# encoding: utf-8

class Api::Auth::AccountsController < Api::AccountsController
  include ApiAuthenticated

  api_versions :v1

  represent_with Api::Auth::AccountRepresenter

  private

  def resources
    self.resources = decorate_query(resources_base)
  end

  def resources_base
    @accounts ||= token_accounts
  end

  def token_accounts
    current_user.approved_accounts = Account.where({ id: prx_auth_token.authorized_resources.keys })
  end
end
