# encoding: utf-8

class Api::AudioFileRepresenter < Api::BaseRepresenter
  property :id, writeable: false
  property :position

  property :filename, writeable: false
  property :label
  property :status, writeable: false
  property :status_message, writeable: false
  property :size
  property :duration

  property :content_type, writeable: false
  property :layer, writeable: false
  property :frequency, writeable: false
  property :bit_rate, writeable: false
  property :channel_mode, writeable: false

  # provide an accessible url to the audio media file for upload
  property :upload, readable: false

  set_link_property(rel: :audio_version, writeable: true)

  set_link_property(rel: :account, writeable: true)

  link :enclosure do
    {
      href: represented.enclosure_url,
      type: represented.enclosure_content_type
    } if represented.id
  end

  link :original do
    {
      href: "#{original_api_audio_file_path(represented)}{?expiration}",
      templated: true,
      type: represented.content_type
    } if represented.id
  end
end
