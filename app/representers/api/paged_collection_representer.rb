# encoding: utf-8
require 'hal_api/paged_collection_representer'

class Api::PagedCollectionRepresenter < HalApi::PagedCollectionRepresenter
  curies(:prx) do
    [{
      name: :prx,
      href: "http://#{profile_host}/relation/{rel}",
      templated: true
    }]
  end

  def self.profile_host
    ENV['META_HOST'] || 'meta.prx.org'
  end
end
