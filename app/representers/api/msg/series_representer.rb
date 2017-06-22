# encoding: utf-8

class Api::Msg::SeriesRepresenter < Api::SeriesRepresenter
  def self_url(represented)
    api_series_path(represented)
  end

  # don't embed the stories, makes this a much smaller message
  embed :public_stories,
        as: :stories,
        paged: true,
        item_class: Story,
        item_decorator: Api::Min::StoryRepresenter,
        zoom: false
end
