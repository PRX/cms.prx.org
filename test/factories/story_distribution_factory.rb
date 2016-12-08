FactoryGirl.define do
  factory :story_distribution do
    distribution
    story
    url "http://feeder.prx.tech/episodes/aguid"
  end

  factory :podcast_episode_distribution, class: 'StoryDistributions::PodcastEpisodeDistribution' do
    distribution factory: :podcast_distribution
    story
    url "http://feeder.prx.tech/episodes/aguid"
    guid "aguid"
  end
end
