# encoding: utf-8

class Api::AudioFileRepresenter < Api::BaseRepresenter

  property :id, writeable: false
  property :filename
  property :label
  property :size
  property :duration

  # provide an accessible url to the audio media file for upload
  property :upload, readable: false

  set_link_property(rel: :audio_version, writeable: true)

  set_link_property(rel: :account, writeable: true)

  link :enclosure do
    {
      href: represented.public_url(version: :broadcast, extension: 'mp3'),
      type: 'audio/mpeg'
    } if represented.id
  end
end
