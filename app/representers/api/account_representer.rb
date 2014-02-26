# encoding: utf-8

class Api::AccountRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL

  property :id
  property :type
  property :name
  property :path

  link :self do
    api_account_path(represented)
  end

  link :opener do
    api_user_path(represented.opener) if represented.opener
  end
  property :opener, embedded: true, class: User, decorator: Api::UserRepresenter, if: -> { self.class == IndividualAccount }

  link :image do
    polymorphic_path(represented.image) if represented.image
  end
  property :image, embedded: true, class: Image, decorator: Api::ImageRepresenter
  
  link :address do
    api_address_path(represented.address) if represented.address
  end
  property :address, embedded: true, class: Address, decorator: Api::AddressRepresenter

end
