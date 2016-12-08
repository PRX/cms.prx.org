# encoding: utf-8

class Api::DistributionRepresenter < Api::BaseRepresenter
  property :id, writeable: false
  property :type
  property :guid
  property :url
  hash :properties

  def self_url(represented)
    polymorphic_path([:api, represented.owner, represented.becomes(Distribution)])
  end

  link :owner do
    {
      href: polymorphic_path([:api, represented.owner]),
      profile: model_uri(represented.owner)
    } if represented.id && represented.owner
  end
end
