# encoding: utf-8

class Api::ProducerRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL

  property :id
  property :user_id
  property :name

  link :self do
    api_producer_path(represented)
  end

  link :user do
    {href: api_user_path(represented.user), name: represented.user.login } if represented.user_id
  end

end
