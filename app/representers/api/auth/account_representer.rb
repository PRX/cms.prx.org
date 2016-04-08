# encoding: utf-8

class Api::Auth::AccountRepresenter < Api::AccountRepresenter

  # point to authorized stories (including unpublished)
  link :stories do
    {
      href: "#{api_authorization_account_stories_path(represented)}{?page,per,zoom,filters}",
      templated: true,
      count: represented.all_stories.count
    }
  end
  embed :stories, get: :all_stories, paged: true, item_class: Story,
                  item_decorator: Api::Auth::StoryMinRepresenter

  def self_url(r)
    api_authorization_account_path(r)
  end

end
