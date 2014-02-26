# encoding: utf-8

class Api::ImageRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL

  property :id
  property :filename
  property :size

  link :enclosure do
    {
      href: represented.public_url,
      type: represented.content_type || 'image'
    }
  end

  link :self do 
    polymorphic_path([:api, represented])
  end

end
