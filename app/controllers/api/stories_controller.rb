class Api::StoriesController < Api::BaseController

  api_versions :v1

  def show
    respond_with Piece.find(params[:id].to_i)
  end

end