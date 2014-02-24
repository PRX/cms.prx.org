# encoding: utf-8

class Api::ImageRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL

  property :id

  link :enclosure do
    {
      href: represented.url,
      type: represented.content_type || 'image'
    }
  end

  link :self do 
    polymorphic_path([:api, represented])
  end

end
