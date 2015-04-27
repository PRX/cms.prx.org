# encoding: utf-8

class Api::PicksController < Api::BaseController

  api_versions :v1

  represent_with Api::PickRepresenter

  def scoped(relation)
    relation.named_playlists
  end
end
