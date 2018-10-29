# encoding: utf-8

class Api::Auth::UsersController < Api::UsersController
  include ApiAuthenticated

  api_versions :v1

  represent_with Api::Min::UserRepresenter
end
