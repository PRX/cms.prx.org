# encoding: utf-8

class PublicAssetsController < ApplicationController

  def show
    version = nil
    asset = params[:class].camelize.constantize.find(params[:id])
    if asset.public_url_valid?(params)
      params[:head] = true if request.head?
      redirect_to asset.asset_url(params)
    else
      head 401
    end
  end

  def options
    headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
    head :no_content
  end

end
