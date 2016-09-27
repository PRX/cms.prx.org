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
    ENV['PRX_HOST'] || 'www.prx.org'
  end

  def self.profile_host
    ENV['META_HOST'] || 'meta.prx.org'
  end

  def index_url_params
    '{?page,per,zoom,filters,sorts}'
  end
end
