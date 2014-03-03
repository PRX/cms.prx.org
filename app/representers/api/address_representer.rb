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
  
end
