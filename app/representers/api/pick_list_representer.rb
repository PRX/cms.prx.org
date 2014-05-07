# encoding: utf-8

class Api::PickListRepresenter < Api::BaseRepresenter

  property :id
  property :title
  property :description

  link :picks do
    api_pick_list_picks_path(represented)
  end
  embed :picks, as: :picks, paged: true, item_class: Pick, item_decorator: Api::PickRepresenter, zoom: true

end
