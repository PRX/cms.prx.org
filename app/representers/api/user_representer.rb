# encoding: utf-8

class Api::UserRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL

  property :id
  property :first_name
  property :last_name
  property :login

  link :self do
    api_user_path(represented)
  end

  link :image do
    api_user_image_path(represented.image) if represented.image
  end
  property :image, embedded: true, class: Image, decorator: Api::ImageRepresenter

end
