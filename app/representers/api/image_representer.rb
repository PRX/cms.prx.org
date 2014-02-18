# encoding: utf-8

class Api::ImageRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL

  property :id
  property :url

  link :self do 
    polymorphic_path([:api, represented.owner, represented])
  end

end
