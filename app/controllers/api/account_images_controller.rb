# encoding: utf-8

class Api::AccountImagesController < Api::BaseController

  api_versions :v1

  filter_resources_by :account_id

  announce_actions decorator: Api::Msg::ImageRepresenter, subject: :image

  represent_with Api::ImageRepresenter

  def resource
    @account_image ||= account.try(:image) || super
  end

  def account
    @account ||= Account.find(params[:account_id]) if params[:account_id]
  end
end
