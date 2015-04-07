# encoding: utf-8

class Api::AccountImagesController < Api::BaseController

  api_versions :v1

  filter_resources_by :account_id

  represent_with Api::ImageRepresenter

  def resource
    @account_image = account.image if !super && account
    @account_image
  end

  def account
    @account ||= Account.find(params[:account_id]) if params[:account_id]
  end
end
