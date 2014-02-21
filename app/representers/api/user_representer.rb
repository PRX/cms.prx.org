# encoding: utf-8

class Api::UserRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL

  property :id
  property :first_name
  property :last_name

  link :self do
    api_user_path(represented)
  end
end
