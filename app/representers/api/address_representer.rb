# encoding: utf-8

class Api::AddressRepresenter < Api::BaseRepresenter

  property :id
  property :street_1
  property :street_2
  property :street_3
  property :postal_code
  property :city
  property :state
  property :country

  def self_url(address)
    addressable = address.addressable
    addressable = addressable.becomes(Account) if addressable.is_a?(Account)
    polymorphic_path([:api, addressable, address])
  end
end
