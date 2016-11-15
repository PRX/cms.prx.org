FactoryGirl.define do
  factory :distribution, class: 'Distributions::PodcastDistribution' do
    distributable factory: :series
    url "http://feed.prx.tech/testpodcast"
    guid "testpodcast"
    properties( { "explicit" => "clean" } )
  end
end
