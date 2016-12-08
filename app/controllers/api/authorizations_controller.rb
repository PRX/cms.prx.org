# encoding: utf-8

class Api::AuthorizationsController < Api::BaseController
  include ApiAuthenticated

  api_versions :v1

  private

  def resource
    current_user
  end
end
