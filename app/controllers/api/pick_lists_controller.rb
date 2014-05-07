class Api::PickListsController < Api::BaseController

  api_versions :v1

  represent_with Api::PickListRepresenter

  def resource
    @pick_list = PickList.find_by_id(params[:id])
  end

# TODO: refactor existing app to have membership record for user to be admin of individual account
# This would be the right thing to do if there was consistency in how accounts are associated to a user.
# Once that TODO above is done, this can be used instead of the `resources` method
  # filter_resources_by :user_id

end

