FactoryGirl.define do
  factory :story_distribution do
    distribution
    story
    url "https://feeder.prx.org/episodes/aguid"
  end

  factory :episode_distribution, class: 'StoryDistributions::EpisodeDistribution' do
    distribution factory: :podcast_distribution
    story
    url "https://feeder.prx.org/episodes/aguid"
    guid "aguid"
  end
end
