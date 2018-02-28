FactoryGirl.define do
  factory :distribution do
    distributable factory: :series
    url 'https://feeder.prx.org/api/v1/podcasts/23'
    guid 'testpodcast'
    properties('explicit' => 'clean')
  end

  factory :podcast_distribution, class: 'Distributions::PodcastDistribution' do
    distributable factory: :series
    url 'https://feeder.prx.org/api/v1/podcasts/23'
    guid 'testpodcast'
    properties('explicit' => 'clean')
  end
end
