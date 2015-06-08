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
    [{ name: :prx, href: "http://meta.prx.org/relation/{rel}", templated: true }]
  end

  link(:self) do
    {
      href:    self_url(represented),
      profile: prx_model_uri(represented)
    }
  end

  def self_url(represented)
    rep = becomes_represented_class(represented)
    polymorphic_path([:api, rep])
  end

  def becomes_represented_class(rep)
    return rep unless rep.respond_to?(:becomes)
    klass = rep.try(:item_class) || rep.class.try(:base_class)
    (klass && (klass != rep.class)) ? rep.becomes(klass) : rep
  end
end
