# encoding: utf-8

class Api::Auth::SeriesRepresenter < Api::SeriesRepresenter
  # point to authorized stories (including unpublished)
  link :stories do
    {
      href: "#{api_authorization_series_stories_path(represented)}#{index_url_params}",
      templated: true,
      count: represented.stories.count
    } if represented.id
  end
  embed :stories,
    paged: true,
    item_class: Story,
    item_decorator: Api::Auth::StoryMinRepresenter,
    url: ->(_r) { api_authorization_series_stories_path(represented.parent) },
    zoom: false

  def self_url(r)
    api_authorization_series_path(r)
  end
end
