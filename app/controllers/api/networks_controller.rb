# encoding: utf-8

class Api::NetworksController < Api::BaseController

  api_versions :v1

  filter_resources_by :account_id
end
