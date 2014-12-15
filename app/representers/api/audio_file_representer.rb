# encoding: utf-8

class Api::AudioFileRepresenter < Api::BaseRepresenter

  property :id
  property :filename
  property :label
  property :size
  property :length, as: :duration

  set_link_property(rel: :audio_version, writeable: true)

  link :enclosure do
    {
      href: represented.public_url(version: :broadcast, extension: 'mp3'),
      type: 'audio/mpeg'
    }
  end

  def self_url(audio_file)
    polymorphic_path([:api, audio_file.audio_version, audio_file])
  end

end
