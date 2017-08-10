# encoding: utf-8

class Api::Auth::AudioFileRepresenter < Api::AudioFileRepresenter
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
