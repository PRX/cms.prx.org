# encoding: utf-8

class Api::Auth::AccountRepresenter < Api::AccountRepresenter
  # point to authorized stories (including unpublished)
  link :stories do
    if represented.id
      {
        href: "#{api_authorization_account_stories_path(represented)}#{index_url_params}",
        templated: true,
        count: represented.stories.count
      }
    end
  end
  embed :stories,
        paged: true,
        item_class: Story,
        item_decorator: Api::Auth::StoryMinRepresenter,
        url: ->(_r) { api_authorization_account_stories_path(represented.parent) }

  def self_url(r)
    api_authorization_account_path(r)
  end
end
