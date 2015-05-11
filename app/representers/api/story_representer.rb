# encoding: utf-8

class Api::StoryRepresenter < Api::BaseRepresenter

  property :id
  property :title
  property :short_description
  property :episode_number
  property :episode_identifier
  property :published_at
  property :produced_on

  property :duration, writeable: false
  property :points, writeable: false
  property :app_version, writeable: false

  property :description
  property :related_website
  property :broadcast_history
  property :timing_and_cues
  property :content_advisory
  property :tags

  property :license, class: License, decorator: Api::LicenseRepresenter

  link rel: :account, writeable: true do
    {
      href: api_account_path(represented.account),
      title: represented.account.name,
      profile: prx_model_uri(represented.account)
    } if represented.account
  end
  embed :account, class: Account, decorator: Api::Min::AccountRepresenter

  link rel: :series, writeable: true do
    {
      href: api_series_path(represented.series),
      title: represented.series.title
    } if represented.series_id
  end
  embed :series, class: Series, decorator: Api::Min::SeriesRepresenter

  link :image do
    {
      href: polymorphic_path([:api, represented.default_image]),
      profile: prx_model_uri(represented.default_image)
    } if represented.default_image
  end
  embed :default_image, as: :image, decorator: Api::ImageRepresenter

  link :audio do
    {
      href: api_story_audio_files_path(represented.id),
      count: represented.default_audio.count
    } if represented.id
  end
  embed :default_audio, as: :audio, paged: true, item_class: AudioFile, per: :all

  link :promos do
    {
      href: api_story_promos_path(represented.id),
      count: represented.promos_audio.count
    } if represented.id
  end
  embed :promos_audio, as: :promos, paged: true, item_class: AudioFile

  link :audio_versions do
    {
      href: api_story_audio_versions_path(represented.id),
      count: represented.audio_versions.count
    } if represented.id
  end
  embed :audio_versions, paged: true, item_class: AudioVersion, zoom: false

  link :images do
    {
      href: api_story_story_images_path(represented),
      count: represented.images.count
    } if represented.id
  end
  embed :images, paged: true, item_class: StoryImage, decorator: Api::ImageRepresenter, zoom: false

  link :musical_works do
    {
      href: "#{api_story_musical_works_path(represented)}{?page,per,zoom}",
      templated: true,
      count: represented.musical_works.count
    } if represented.id
  end
  embed :musical_works, paged: true, item_class: MusicalWork, zoom: false
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
