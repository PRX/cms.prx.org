class Api::PickListsController < Api::BaseController

  api_versions :v1

  represent_with Api::PickListRepresenter

  def resource
    @pick_list = PickList.find_by_id(params[:id])
  end

end

