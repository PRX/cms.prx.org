# encoding: utf-8

class Api::Min::StoryRepresenter < Api::BaseRepresenter

  property :id
  property :title
  property :duration
  property :short_description
  property :published_at
  property :produced_on
  property :points

  # default zoom
  link :account do
    {
      href: api_account_path(represented.account),
      title: represented.account.name,
      profile: prx_model_uri(represented.account)
    }
  end
  embed :account, class: Account, decorator: Api::Min::AccountRepresenter

  link :image do
    api_story_image_path(represented.default_image.id) if represented.default_image
  end
  embed :default_image, as: :image, class: StoryImage, decorator: Api::ImageRepresenter

  link :series do
    {
      href: api_series_path(represented.series),
      title: represented.series.title
    } if represented.series_id
  end
  embed :series, class: Series, decorator: Api::Min::SeriesRepresenter

  links :audio do
    represented.default_audio.collect{ |a| { href: api_audio_file_path(a), title: a.label } }
  end
  embeds :default_audio, as: :audio, class: AudioFile, decorator: Api::AudioFileRepresenter

end
