# encoding: utf-8

class Api::StoryRepresenter < Api::BaseRepresenter

  property :id
  property :title
  property :short_description
  property :description
  property :episode_number
  property :episode_identifier
  property :published_at
  property :produced_on
  property :related_website
  property :broadcast_history
  property :timing_and_cues
  property :content_advisory
  property :tags
  property :duration, writeable: false
  property :points, writeable: false

  # default zoom
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

  links :audio do
    represented.default_audio.collect{ |a| { href: api_audio_file_path(a), title: a.label } }
  end
  embeds :default_audio, as: :audio, class: AudioFile, decorator: Api::AudioFileRepresenter

  # default links
  link :promos do
    api_audio_version_path(represented.promos.id) if represented.promos
  end
  embed :promos, class: AudioVersion, decorator: Api::AudioVersionRepresenter, zoom: false

  links :audio_versions do
    represented.audio_versions.collect{ |a| { href: api_audio_version_path(a), title: a.label } }
  end
  embeds :audio_versions, class: AudioVersion, decorator: Api::AudioVersionRepresenter, zoom: false

  links :images do
    represented.images.collect{ |a| { href: api_story_image_path(a) } } unless represented.image_ids.size > 0
  end
  embeds :images, class: StoryImage, decorator: Api::ImageRepresenter, zoom: false

  link :'prx:license' do
    api_license_path(represented.license.id) if represented.license
  end
  embed :license, as: :'prx:license', class: License, decorator: Api::LicenseRepresenter

  link :musical_works do
    api_story_musical_works_path(represented) if represented.id
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
