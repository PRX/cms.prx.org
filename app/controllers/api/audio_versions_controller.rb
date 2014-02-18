class Api::AudioVersionsController < Api::BaseController

  api_versions :v1

  def show
    respond_with AudioVersion.find(params[:id].to_i)
  end

end
