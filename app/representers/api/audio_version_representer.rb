# encoding: utf-8

class Api::AudioVersionRepresenter < Api::BaseRepresenter

  property :id
  property :label
  property :timing_and_cues

  link :audio do
    api_audio_version_audio_files_path(represented)
  end
  embeds :audio_files, as: :audio, class: AudioFile, decorator: Api::AudioFileRepresenter

end
