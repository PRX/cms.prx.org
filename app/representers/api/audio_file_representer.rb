# encoding: utf-8

class Api::AudioFileRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL

  property :id
  property :filename
  property :label
  property :size
  property :length, as: :duration
  
  link :enclosure do
    {
      href: represented.public_url(version: :download, extension: 'mp3'),
      type: 'audio/mpeg'
    }
  end

  link :self do
    api_audio_file_path(represented)
  end

end
