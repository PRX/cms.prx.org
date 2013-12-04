class Api::StoriesController < Api::BaseController

  def show
    render json: {title: params[:api_version]}
  end

end