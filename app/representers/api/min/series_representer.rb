# encoding: utf-8

class Api::Min::SeriesRepresenter < Api::BaseRepresenter
  property :id, writeable: false
  property :title
  property :short_description
  property :app_version, writeable: false

  alternate_link

  link :stories do
    {
      href: "#{api_series_stories_path(represented)}#{index_url_params}",
      templated: true,
      count: represented.public_stories.count
    } if represented.id
  end
  embed :public_stories,
    as: :stories,
    paged: true,
    item_class: Story,
    item_decorator: Api::Min::StoryRepresenter

  link :image do
    api_series_image_path(represented.image) if represented.image
  end
  embed :image, class: SeriesImage, decorator: Api::ImageRepresenter

  link :account do
    {
      href: api_account_path(represented.account),
      title: represented.account.name,
      profile: model_uri(represented.account)
    }
  end
  embed :account, class: Account, decorator: Api::Min::AccountRepresenter, zoom: false
end
