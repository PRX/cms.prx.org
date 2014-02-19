class Api::MusicalWorksController < Api::BaseController

  api_versions :v1

  def show
    respond_with MusicalWork.find(params[:id].to_i)
  end

end
