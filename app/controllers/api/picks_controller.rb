class Api::PicksController < Api::BaseController

  api_versions :v1

  represent_with Api::PickRepresenter

  def resources
    @picks = Pick.all.page(params[:page])
  end

end


