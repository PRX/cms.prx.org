# encoding: utf-8

class Api::Auth::AccountMinRepresenter < Api::Min::AccountRepresenter

  # point to authorized stories (including unpublished)
  link :stories do
    {
      href: "#{api_authorization_account_stories_path(represented)}{?page,per,zoom,filters}",
      templated: true
    }
  end
  embed :all_stories, as: :stories, paged: true, item_class: Story,
                      item_decorator: Api::Auth::StoryMinRepresenter, zoom: false

  def self_url(r)
    api_authorization_account_path(r)
  end

end
