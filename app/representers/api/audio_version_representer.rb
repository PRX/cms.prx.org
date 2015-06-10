# encoding: utf-8

class Api::AudioVersionRepresenter < Api::BaseRepresenter

  property :id, writeable: false
  property :label
  property :timing_and_cues
  property :explicit

  set_link_property(rel: :story, writeable: true)

  link :audio do
    {
      href: api_audio_version_audio_files_path(represented),
      count: represented.audio_files.count
    } if represented.id
  end
  embeds :audio_files, as: :audio, class: AudioFile, decorator: Api::AudioFileRepresenter
end
