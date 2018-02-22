require 'test_helper'

describe Distributions::PodcastDistribution do

  let(:series) { create(:series) }
  let(:template) { create(:audio_version_template, series: series) }
  let(:distribution) { create(:podcast_distribution, distributable: series) }
  let(:podcast_url) { URI.join(distribution.feeder_root, '/api/v1/podcasts/23').to_s }
  let(:episode_distribution) { create(:episode_distribution, url: nil, distribution: distribution) }
  let(:episode_url) { URI.join(distribution.feeder_root, '/api/v1/episodes/aguid').to_s }

  before do
    clear_messages

    stub_request(:get, 'https://feeder.prx.org/api/v1').
      with(headers: { 'Content-Type' => 'application/json' }).
      to_return(status: 200, body: json_file('feeder_root'))

    stub_request(:post, 'https://feeder.prx.org/api/v1/podcasts').
      with(headers: { 'Authorization' => 'Bearer token', 'Content-Type' => 'application/json' }).
      to_return(status: 200, body: json_file('podcast'), headers: {})

    stub_request(:post, 'https://feeder.prx.org/api/v1/podcasts').
      with(headers: { 'Authorization' => 'Bearer fail', 'Content-Type' => 'application/json' }).
      to_return(status: 500, body: "{'code':'500', 'message':'dupe'}", headers: {})

    stub_request(:get, 'https://feeder.prx.org/api/v1/podcasts/23').
      with(headers: { 'Authorization' => 'Bearer token', 'Content-Type' => 'application/json' }).
      to_return(status: 200, body: json_file('podcast'), headers: {})

    stub_request(:get, "https://feeder.prx.org/api/v1/authorization/episodes/aguid").
      with(:headers => {'Authorization'=>'Bearer token', 'Content-Type'=>'application/json'}).
      to_return(status: 200, body: json_file('episode'), headers: {})
  end

  it 'returns episode distribution class' do
    distribution.story_distribution_class.must_equal StoryDistributions::EpisodeDistribution
  end

  it 'creates the podcast on feeder' do
    distribution.stub(:get_account_token, 'token') do
      distribution.url = nil
      distribution.account.wont_be_nil
      distribution.save!
      distribution.distribute!
      distribution.url.must_equal(podcast_url)
    end
  end

  it 'throws error and rolls back if podcast on feeder fails' do
    distribution.stub(:get_account_token, 'fail') do
      distribution.url = nil
      distribution.account.wont_be_nil
      distribution.save!
      -> { distribution.distribute! }.must_raise(HyperResource::ServerError)
    end
  end

  it 'retrieves the podcast from feeder' do
    distribution.stub(:get_account_token, 'token') do
      distribution.url = podcast_url
      podcast = distribution.get_podcast
      podcast.wont_be_nil
      podcast.id.must_equal 23
    end
  end

  it 'returns attributes for creating the podcast' do
    attrs = distribution.podcast_attributes
    attrs.keys.count.must_equal 6
    attrs[:prx_uri].must_equal "/api/v1/series/#{distribution.owner.id}"
    attrs[:prx_account_uri].must_equal "/api/v1/accounts/#{distribution.account.id}"
    attrs[:published_at].wont_be_nil
  end

  it 'doesnt send image info on create' do
    attrs = distribution.podcast_attributes
    attrs.keys.each { |key| key.to_s.wont_match /image/ }
  end

  it 'returns if distributed' do
    distribution.url.wont_be_nil
    distribution.must_be :distributed?
  end

  it 'returns if published' do
    distribution.stub(:get_account_token, 'token') do
      distribution.must_be :published?
    end
  end

  it 'can publish' do
    distribution.stub(:get_account_token, 'token') do
      distribution.distributable.must_equal series
      distribution.publish!
      announcement = published_messages.first
      announcement['subject'].must_equal :series
      announcement['action'].must_equal :update
    end
  end

  it 'checks stories_published' do
    episode_distribution.stub(:get_account_token, 'token') do
      episode_distribution.wont_be_nil
      episode_distribution.wont_be :distributed?
      episode_distribution.wont_be :published?

      distribution.story_distributions.count.must_equal 1
      distribution.wont_be :stories_published?

      episode_distribution.update_attributes(url: episode_url)
      episode_distribution.must_be :distributed?
      episode_distribution.must_be :published?
      distribution.story_distributions = [episode_distribution]
      distribution.must_be :stories_published?
    end
  end
end
