# encoding: utf-8

class Api::AddressRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL

  property :id
  property :street_1
  property :street_2
  property :street_3
  property :postal_code
  property :city
  property :state
  property :country

  link :self do
    api_address_path(represented)
  end

end
