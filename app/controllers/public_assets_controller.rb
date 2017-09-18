# encoding: utf-8

class PublicAssetsController < ApplicationController
  def show(options = {})
    if asset = find_asset
      if asset.public_url_valid?(params)
        redirect_to asset.asset_url params.merge(options)
      else
        head 401
      end
    else
      head 404
    end
  end

  def show_head
    show(head:true)
  end

  def show_options
    headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
    head :no_content
  end

  private

  def find_asset
    params[:class].camelize.constantize.find_by_id(params[:id])
  end
end
