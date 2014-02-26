# encoding: utf-8

class Api::SeriesRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL
  include Api::UrlRepresenterHelper

  property :id
  property :title
  property :short_description
  property :description
  property :story_count
  
  link :self do
    api_series_path(represented)
  end

  link :stories do
    api_series_stories_path(represented)
  end

  link :image do
    api_series_image_path(represented.image) if represented.image
  end
  property :image, embedded: true, class: SeriesImage, decorator: Api::ImageRepresenter

  link :account do
    {
      href: api_account_path(represented.account),
      name: represented.account.name,
      profile: prx_model_uri(represented.account)
    }
  end
  property :account, embedded: true, class: Account, decorator: Api::AccountRepresenter

end
