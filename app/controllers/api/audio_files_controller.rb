class Api::AudioFilesController < Api::BaseController

  api_versions :v1

  def show
    respond_with AudioFile.find(params[:id].to_i)
  end

end
