# encoding: utf-8

class PublicAssetsController < ApplicationController

  def show
    if asset = find_valid_asset
      redirect_to asset.asset_url(params)
    else
      head 401
    end
  end

  def show_head
    if asset = find_valid_asset
      redirect_to asset.asset_url params.merge(head: true)
    else
      head 401
    end
  end

  def show_options
    headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
    head :no_content
  end

  private

  def find_valid_asset
    asset = params[:class].camelize.constantize.find(params[:id])
    asset if asset.public_url_valid?(params)
  end

end
