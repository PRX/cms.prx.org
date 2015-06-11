# encoding: utf-8

class Api::BaseRepresenter < Roar::Decorator

  include Roar::Representer::JSON::HAL

  include FormatKeys
  include UriMethods
  include Curies
  include Embeds
  include Caches
  include LinkSerialize

  curies(:prx) do
    [{
      name: :prx,
      href: "http://#{prx_meta_host}/relation/{rel}",
      templated: true
    }]
  end

  self_link

  profile_link
end
