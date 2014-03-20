# encoding: utf-8

class Api::Min::SeriesRepresenter < Api::BaseRepresenter

  property :id
  property :title
  property :short_description
  property :story_count
  
  link :stories do
    api_series_stories_path(represented)
  end
  embed :stories, paged: true, item_class: Story, item_decorator: Api::Min::StoryRepresenter, zoom: false

  link :image do
    api_series_image_path(represented.image) if represented.image
  end
  embed :image, class: SeriesImage, decorator: Api::ImageRepresenter

  link :account do
    {
      href: api_account_path(represented.account),
      title: represented.account.name,
      profile: prx_model_uri(represented.account)
    }
  end
  embed :account, class: Account, decorator: Api::AccountRepresenter

end
