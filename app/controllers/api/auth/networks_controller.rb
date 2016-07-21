# encoding: utf-8

class Api::Auth::NetworksController < Api::AccountsController

  include ApiAuthenticated

  api_versions :v1

  represent_with Api::Auth::NetworkRepresenter

  private

  def resources
    self.resources = decorate_query(resources_base)
  end

  def resources_base
    @networks ||= current_user.networks
  end

end
