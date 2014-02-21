# encoding: utf-8

class Api::AccountRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL

  property :id
  property :name
  property :type

  property :image, embedded: true, class: AccountImage, decorator: Api::ImageRepresenter
  
  link :self do
    api_account_path(represented)
  end

end
