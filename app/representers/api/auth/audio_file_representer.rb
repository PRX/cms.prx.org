# encoding: utf-8

class Api::Auth::AudioFileRepresenter < Api::AudioFileRepresenter
  property :content_type, writeable: false
  property :layer, writeable: false
  property :frequency, writeable: false
  property :bit_rate, writeable: false
  property :channel_mode, writeable: false

  def self_url(r)
    api_authorization_audio_file_path(r)
  end

  link :storage do
    {
      href: represented.fixerable_final_storage_url,
      type: represented.content_type
    } if represented.id
  end
end
