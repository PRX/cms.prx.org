# encoding: utf-8

class Api::StoryRepresenter < Api::BaseRepresenter

  property :id
  property :title
  property :length
  property :short_description
  property :description
  property :published_at
  property :produced_on
  property :points
  property :related_website
  property :broadcast_history
  property :timing_and_cues, decorator_scope: true

  def timing_and_cues
    represented.default_audio_version.try(:timing_and_cues)
  end

  link :account do
    {
      href: api_account_path(represented.account),
      title: represented.account.name,
      profile: prx_model_uri(represented.account)
    }
  end
  embed :account, class: Account, decorator: Api::AccountRepresenter

  link :image do
    api_story_image_path(represented.default_image.id) if represented.default_image
  end
  embed :default_image, as: :image, class: StoryImage, decorator: Api::ImageRepresenter

  link :series do
    { href: api_series_path(represented.series), title: represented.series.title } if represented.series_id
  end
  embed :series, class: Series, decorator: Api::SeriesRepresenter

  link :'prx:license' do
    api_license_path(represented.license.id) if represented.license
  end

  link :musical_works do
    api_story_musical_works_path(represented)
  end

  links :audio do
    represented.default_audio.collect{ |a| { href: api_audio_file_path(a), title: a.label } }
  end
  embeds :default_audio, as: :audio, class: AudioFile, decorator: Api::AudioFileRepresenter

  links :audio_versions do
    represented.audio_versions.collect{ |a| { href: api_audio_version_path(a), title: a.label } }
  end

  links :images do
    represented.images.collect{ |a| { href: api_story_image_path(a) } } unless represented.image_ids.size > 0
  end

end

# TODO:
# * List of Producers
# * tags

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
