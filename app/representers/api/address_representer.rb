# encoding: utf-8

class Api::AddressRepresenter < Api::BaseRepresenter
  property :id, writeable: false
  property :street_1
  property :street_2
  property :street_3
  property :postal_code
  property :city
  property :state
  property :country

  def self_url(address)
    api_account_address_path(address.account_id) if address.account_id
  end
end
