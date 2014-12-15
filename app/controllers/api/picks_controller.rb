# encoding: utf-8

class Api::PicksController < Api::BaseController

  api_versions :v1

  represent_with Api::PickRepresenter

  def resources
    @picks = Pick.named_playlists.page(params[:page])
  end

end


