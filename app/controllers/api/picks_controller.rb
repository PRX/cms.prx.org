class Api::PicksController < Api::BaseController

  api_versions :v1

  represent_with Api::PickRepresenter

  def resources
    if params[:pick_list_id]
        @picks = PickList.find_by_id_or_path(params[:pick_list_id]).picks.page(params[:page])
    elsif params[:tag]
        @picks = Pick.tagged(params[:tag]).page(params[:page])
    else
        @picks = Pick.all.page(params[:page])
    end
  end

end


