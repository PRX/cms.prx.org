# encoding: utf-8

class Api::Auth::AudioVersionRepresenter < Api::AudioVersionRepresenter

  def self_url(r)
    api_authorization_audio_version_path(r)
  end

  link :audio do
    {
      href: api_authorization_audio_version_audio_files_path(represented),
      count: represented.audio_files.count
    } if represented.id
  end
  embeds :audio_files, as: :audio, class: AudioFile, decorator: Api::Auth::AudioFileRepresenter
end
