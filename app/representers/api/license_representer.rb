# encoding: utf-8

class Api::LicenseRepresenter < Roar::Decorator

  include Roar::Representer::JSON::HAL
  include Caches

  property :streamable
  property :editable
end
