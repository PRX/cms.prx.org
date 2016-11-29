FactoryGirl.define do
  factory :distribution do
    distributable factory: :series
    url "http://feed.prx.tech/testpodcast"
    guid "testpodcast"
    properties( { "explicit" => "clean" } )
  end

  factory :podcast_distribution, class: 'Distributions::PodcastDistribution' do
    distributable factory: :series
    url "http://feed.prx.tech/testpodcast"
    guid "testpodcast"
    properties( { "explicit" => "clean" } )
  end
end
