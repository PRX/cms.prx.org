# encoding: utf-8

class Api::Auth::NetworkRepresenter < Api::NetworkRepresenter
  # point to authorized stories (including unpublished)
  link :stories do
    {
      href: "#{api_authorization_network_stories_path(represented)}{?page,per,zoom,filters}",
      templated: true,
      count: represented.all_stories.count
    } if represented.id
  end
  embed :all_stories, as: :stories, paged: true, item_class: Story,
                      item_decorator: Api::Auth::StoryMinRepresenter,
                      url: ->(_r) { api_authorization_network_stories_path(represented.parent) }

  def self_url(r)
    api_authorization_network_path(r)
  end
end
