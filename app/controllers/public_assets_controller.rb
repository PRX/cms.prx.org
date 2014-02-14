class PublicAssetsController < ApplicationController

  def show
    version = nil
    asset = params[:class].camelize.constantize.find(params[:id])
    if asset.public_url_valid?(params)
      redirect_to asset.asset_url(params)
    else
      head 401
    end
  end

end
