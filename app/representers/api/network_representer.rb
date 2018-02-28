# encoding: utf-8

class Api::NetworkRepresenter < Api::BaseRepresenter
  property :id, writeable: false
  property :path
  property :name
  property :description
  property :pricing_strategy
  property :publishing_strategy
  property :notification_strategy

  alternate_link

  link rel: :account, writeable: true do
    if represented.account
      {
        href: api_account_path(represented.account),
        title: represented.account.name,
        profile: model_uri(represented.account)
      }
    end
  end
  embed :account, class: Account, decorator: Api::Min::AccountRepresenter

  link :stories do
    if represented.id
      {
        href: "#{api_network_stories_path(represented)}#{index_url_params}",
        templated: true,
        count: represented.public_stories.count
      }
    end
  end
  embed :public_stories,
        as: :stories,
        paged: true,
        item_class: Story,
        item_decorator: Api::Min::StoryRepresenter
end
