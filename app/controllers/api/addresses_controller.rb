# encoding: utf-8

class Api::AddressesController < Api::BaseController

  api_versions :v1

  filter_resources_by :user_id, :account_id

end
