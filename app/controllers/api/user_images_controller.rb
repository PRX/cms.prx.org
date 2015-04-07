# encoding: utf-8

class Api::UserImagesController < Api::BaseController

  api_versions :v1

  filter_resources_by :user_id

  represent_with Api::ImageRepresenter

  def resource
    @user_image = user.image if !super && user
    @user_image
  end

  def user
    @user ||= User.find(params[:user_id]) if params[:user_id]
  end
end
