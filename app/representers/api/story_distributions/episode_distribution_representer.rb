class Api::StoryDistributions::EpisodeDistributionRepresenter < Api::StoryDistributionRepresenter
  link :episode do
    {
      href: represented.url,
      profile: model_uri(:episode)
    }
  end
end
