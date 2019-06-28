# encoding: utf-8

class Api::SeriesRepresenter < Api::BaseRepresenter
  property :id, writeable: false
  property :title
  property :short_description
  property :description_html, as: :description
  property :description_md
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
        item_decorator: Api::Min::StoryRepresenter,
        zoom: false

  link :stories_search do
    {
      href: "#{search_api_series_stories_path(represented)}#{search_url_params}",
      templated: true,
      count: represented.public_stories.count
    } if represented.id
  end

  link :image do
    {
      href: api_series_series_image_path(represented, represented.default_image),
      title: represented.default_image.try(:filename)
    } if represented && represented.default_image
  end
  embed :default_image,
        as: :image,
        class: SeriesImage,
        decorator: Api::ImageRepresenter

  link :images do
    {
      href: api_series_series_images_path(represented),
      count: represented.images.count
    } if represented.id
  end
  embed :images,
        paged: true,
        item_class: SeriesImage,
        item_decorator: Api::ImageRepresenter,
        zoom: false

  link rel: :account, writeable: true do
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
        item_decorator: Api::DistributionRepresenter,
        per: :all

  link :podcast_imports do
    {
      href: api_authorization_series_podcast_imports_path(represented),
      count: represented.podcast_imports.count
    } if represented.id
  end
  embed :podcast_imports,
        paged: true,
        item_class: PodcastImport,
        item_decorator: Api::PodcastImportRepresenter,
        per: :all,
        zoom: false

  link :calendar do
    {
      href: api_series_calendar_path(represented, format: :ics)
    } if represented.id
  end
end
