class Api::PickListsController < Api::BaseController

  api_versions :v1

  represent_with Api::PickListRepresenter

  def resource
    @pick_list = PickList.find_by_id_or_path(params[:id])
  end

  def resources
    @pick_lists = PickList.named.page(params[:page])
  end

end

