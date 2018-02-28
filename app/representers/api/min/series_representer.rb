# encoding: utf-8

class Api::Min::SeriesRepresenter < Api::BaseRepresenter
  property :id, writeable: false
  property :title
  property :short_description
  property :app_version, writeable: false

  alternate_link

  link :stories do
    if represented.id
      {
        href: "#{api_series_stories_path(represented)}#{index_url_params}",
        templated: true,
        count: represented.public_stories.count
      }
    end
  end
  embed :public_stories,
        as: :stories,
        paged: true,
        item_class: Story,
        item_decorator: Api::Min::StoryRepresenter,
        zoom: false

  link :image do
    if represented && represented.default_image
      {
        href: api_series_series_image_path(represented, represented.default_image),
        title: represented.default_image.try(:filename)
      }
    end
  end
  embed :default_image, as: :image, class: SeriesImage, decorator: Api::ImageRepresenter

  link :account do
    {
      href: api_account_path(represented.account),
      title: represented.account.name,
      profile: model_uri(represented.account)
    }
  end
  embed :account, class: Account, decorator: Api::Min::AccountRepresenter, zoom: false

  link :distributions do
    if represented.id
      {
        href: api_series_distributions_path(represented),
        count: represented.distributions.count
      }
    end
  end

  link :audio_version_templates do
    if represented.id
      {
        href: api_series_audio_version_templates_path(represented),
        count: represented.audio_version_templates.count
      }
    end
  end
end
