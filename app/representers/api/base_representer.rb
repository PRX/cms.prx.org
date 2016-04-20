# encoding: utf-8
require 'hal_api/representer'

class Api::BaseRepresenter < HalApi::Representer
  curies(:prx) do
    [{
      name: :prx,
      href: "http://#{profile_host}/relation/{rel}",
      templated: true
    }]
  end

  def self.alternate_host
    "www.prx.org"
  end

  def self.profile_host
    "meta.prx.org"
  end
end
