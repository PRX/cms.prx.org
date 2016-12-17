# encoding: utf-8

class Api::SeriesRepresenter < Api::BaseRepresenter
  property :id, writeable: false
  property :title
  property :short_description
  property :description
  property :created_at, writeable: false
  property :updated_at, writeable: false
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
    {
      href: api_series_series_image_path(represented, represented.default_image),
      title: represented.default_image.try(:filename)
    } if represented && represented.default_image
  end
  embed :default_image, as: :image, class: SeriesImage, decorator: Api::ImageRepresenter

  link :images do
    {
      href: api_series_series_images_path(represented),
      count: represented.images.count
    } if represented.id
  end
  embed :images, paged: true, item_class: SeriesImage, decorator: Api::ImageRepresenter, zoom: false

  link :account do
    {
      href: api_account_path(represented.account),
      title: represented.account.name,
      profile: model_uri(represented.account)
    } if represented.id && represented.account
  end
  embed :account, class: Account, decorator: Api::Min::AccountRepresenter

  link :audio_version_templates do
    {
      href: api_series_audio_version_templates_path(represented),
      count: represented.audio_version_templates.count
    } if represented.id
  end
  embed :audio_version_templates,
        paged: true,
        item_class: AudioVersionTemplate,
        item_decorator: Api::AudioVersionTemplateRepresenter,
        zoom: false

  link :distributions do
    {
      href: api_series_distributions_path(represented),
      count: represented.distributions.count
    } if represented.id
  end
  embed :distributions,
        paged: true,
        item_class: Distribution,
        item_decorator: Api::DistributionRepresenter
end
