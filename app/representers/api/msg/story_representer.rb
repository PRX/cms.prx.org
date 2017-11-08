# encoding: utf-8

class Api::Msg::StoryRepresenter < Api::StoryRepresenter
  def self_url(represented)
    api_story_path(represented)
  end

  # main thing needed here is the audio with the s3 notifications
  link :audio do
    {
      href: api_authorization_audio_files_path(represented.id),
      count: represented.default_audio.count
    } if represented.id
  end
  embed :default_audio,
        as: :audio,
        paged: true,
        item_class: AudioFile,
        item_decorator: Api::Auth::AudioFileRepresenter,
        per: :all

  embed :images,
        paged: true,
        item_class: StoryImage,
        item_decorator: Api::ImageRepresenter,
        per: :all,
        zoom: true
end
