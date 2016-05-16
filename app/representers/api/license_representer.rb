# encoding: utf-8
require 'hal_api/representer/caches'

class Api::LicenseRepresenter < Roar::Decorator

  include Roar::JSON::HAL
  include HalApi::Representer::Caches

  property :streamable
  property :editable
end
