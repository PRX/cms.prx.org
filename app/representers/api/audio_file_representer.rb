# encoding: utf-8

class Api::AudioFileRepresenter < Api::BaseRepresenter

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

end
