# encoding: utf-8

class Api::Auth::AudioVersionRepresenter < Api::AudioVersionRepresenter
  # embed with authorized representer
  embeds :audio_files, as: :audio, class: AudioFile, decorator: Api::Auth::AudioFileRepresenter
end
