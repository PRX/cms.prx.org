# encoding: utf-8

class Api::AddressesController < Api::BaseController

  api_versions :v1

  filter_resources_by :account_id

  def resource
    @address ||= account.try(:address) || super
  end

  def account
    @account ||= Account.find(params[:account_id]) if params[:account_id]
  end
end
