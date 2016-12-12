# encoding: utf-8

class Api::Distributions::PodcastDistributionRepresenter < Api::DistributionRepresenter
  link :podcast do
    {
      href: represented.url,
      profile: model_uri(:podcast)
    }
  end
end
