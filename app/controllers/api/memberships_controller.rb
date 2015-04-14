# encoding: utf-8

class Api::MembershipsController < Api::BaseController

  api_versions :v1

  filter_resources_by :account_id, :user_id
end
