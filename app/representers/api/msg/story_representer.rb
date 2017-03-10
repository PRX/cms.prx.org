# encoding: utf-8

class Api::Msg::StoryRepresenter < Api::StoryRepresenter
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
end
