# encoding: utf-8

class Api::AudioFileRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL

  property :id
  property :filename
  property :label
  property :url, decorator_scope: true
  
  def url
    represented.public_url(version: :download, extension: 'mp3')
  end

  link :self do
    api_audio_file_path(represented)
  end
end
