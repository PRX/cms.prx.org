# encoding: utf-8

class Api::PodcastDistributionRepresenter < Api::DistributionRepresenter
  link :podcast do
    {
      href: url,
      profile: model_uri(:podcast)
    }
  end
end
