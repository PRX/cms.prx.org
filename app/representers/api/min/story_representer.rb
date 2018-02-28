# encoding: utf-8

class Api::Min::StoryRepresenter < Api::BaseRepresenter
  property :id, writeable: false
  property :title
  property :clean_title
  property :short_description
  property :episode_number
  property :episode_identifier
  property :season_identifier
  property :created_at, writeable: false
  property :updated_at, writeable: false
  property :published_at, writeable: false
  property :produced_on

  property :status, writeable: false
  property :status_message, writeable: false

  property :duration, writeable: false
  property :points, writeable: false
  property :app_version, writeable: false

  alternate_link

  link :account do
    if represented.account
      {
        href: api_account_path(represented.account),
        title: represented.account.name,
        profile: model_uri(represented.account)
      }
    end
  end
  embed :account, class: Account, decorator: Api::Min::AccountRepresenter, zoom: false

  link :series do
    if represented.series
      {
        href: api_series_path(represented.series),
        title: represented.series.title
      }
    end
  end
  embed :series, class: Series, decorator: Api::Min::SeriesRepresenter, zoom: false

  link :image do
    if represented.default_image
      {
        href: api_story_story_image_path(represented, represented.default_image),
        title: represented.default_image.try(:filename)
      }
    end
  end
  embed :default_image, as: :image, decorator: Api::ImageRepresenter

  link :audio do
    if represented.id
      {
        href: api_story_audio_files_path(represented.id),
        count: represented.default_audio.count
      }
    end
  end
  embed :default_audio, as: :audio, paged: true, item_class: AudioFile, per: :all

  link :promos do
    if represented.id
      {
        href: api_story_promos_path(represented.id),
        count: represented.promos_audio.count
      }
    end
  end
  embed :promos_audio, as: :promos, paged: true, item_class: AudioFile, per: :all
end
