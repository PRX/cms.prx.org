# encoding: utf-8

class Api::Msg::SeriesRepresenter < Api::SeriesRepresenter
  # don't embed the stories, makes this a much smaller message
  embed :public_stories,
        as: :stories,
        paged: true,
        item_class: Story,
        item_decorator: Api::Min::StoryRepresenter,
        zoom: false
end
