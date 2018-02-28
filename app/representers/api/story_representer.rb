# encoding: utf-8

class Api::StoryRepresenter < Api::BaseRepresenter
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
  property :released_at
  property :produced_on

  property :duration, writeable: false
  property :points, writeable: false
  property :app_version, writeable: false
  property :status, writeable: false
  property :status_message, writeable: false

  property :description_html, as: :description
  property :description_md
  property :related_website
  property :broadcast_history
  property :timing_and_cues
  property :content_advisory
  property :tags
  property :transcript

  property :license, class: License, decorator: Api::LicenseRepresenter

  alternate_link

  link rel: :publish, writeable: false do
    if represented.published_at.nil?
      {
        href: publish_api_story_path(represented)
      }
    end
  end

  link rel: :unpublish, writeable: false do
    if !represented.published_at.nil?
      {
        href: unpublish_api_story_path(represented)
      }
    end
  end

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

  link rel: :series, writeable: true do
    if represented.series_id
      {
        href: api_series_path(represented.series),
        title: represented.series.title
      }
    end
  end
  embed :series, class: Series, decorator: Api::Min::SeriesRepresenter

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

  link :audio_versions do
    if represented.id
      {
        href: api_story_audio_versions_path(represented.id),
        count: represented.audio_versions.count
      }
    end
  end
  embed :audio_versions, paged: true, item_class: AudioVersion, per: :all

  link :images do
    if represented.id
      {
        href: api_story_story_images_path(represented),
        count: represented.images.count
      }
    end
  end
  embed :images,
        paged: true,
        item_class: StoryImage,
        item_decorator: Api::ImageRepresenter,
        zoom: false

  link :musical_works do
    if represented.id
      {
        href: "#{api_story_musical_works_path(represented)}#{index_url_params}",
        templated: true,
        count: represented.musical_works.count
      }
    end
  end
  embed :musical_works, paged: true, item_class: MusicalWork, zoom: false

  link :distributions do
    if represented.id
      {
        href: api_story_story_distributions_path(represented),
        count: represented.distributions.count
      }
    end
  end
  embed :distributions,
        paged: true,
        item_class: StoryDistribution,
        item_decorator: Api::StoryDistributionRepresenter,
        per: :all
end

# TODO:
# * List of Producers

# WAIT:
# * Producing Account's other Pieces (Doesn't make sense for right now)

# requires castle integration
# * Purchase Count
# * Listen Count (don't know if this makes sense to have here)

# requires search/solr integration
# * Related Pieces (obviously low priority)

# requires fb integration
# * Like Count (don't think this exists)

# doesn't exist
# * Accomplishments (Don't think this exists)
