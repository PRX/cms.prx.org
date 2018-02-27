require 'test_helper'

describe StoryDistributions::EpisodeDistribution do

  let(:podcast_distribution) { create(:podcast_distribution) }
  let(:distribution) { build(:episode_distribution, distribution: podcast_distribution) }
  let(:episode_url) { URI.join(distribution.feeder_root, '/api/v1/episodes/aguid').to_s }

  before do
    stub_request(:get, 'https://feeder.prx.org/api/v1').
      with(headers: { 'Authorization' => 'Bearer token', 'Content-Type' => 'application/json' }).
      to_return(status: 200, body: json_file('feeder_root'))

    stub_request(:post, 'https://feeder.prx.org/api/v1/podcasts').
      with(headers: { 'Authorization' => 'Bearer token', 'Content-Type' => 'application/json' }).
      to_return(status: 200, body: json_file('podcast'), headers: {})

    stub_request(:get, 'https://feeder.prx.org/api/v1/podcasts/23').
      with(headers: { 'Authorization' => 'Bearer token', 'Content-Type' => 'application/json' }).
      to_return(status: 200, body: json_file('podcast'), headers: {})

    stub_request(:get, 'https://feeder.prx.org/api/v1/podcasts/23/episodes').
      with(headers: { 'Authorization' => 'Bearer token', 'Content-Type' => 'application/json' }).
      to_return(status: 200, body: json_file('episodes'), headers: {})

    stub_request(:post, 'https://feeder.prx.org/api/v1/podcasts/23/episodes').
      with(headers: { 'Authorization' => 'Bearer token', 'Content-Type' => 'application/json' }).
      to_return(status: 200, body: json_file('episode'), headers: {})

    stub_request(:get, "https://feeder.prx.org/api/v1/authorization/episodes/aguid").
      with(:headers => {'Authorization'=>'Bearer token', 'Content-Type'=>'application/json'}).
      to_return(status: 200, body: json_file('episode'), headers: {})

  end

  it 'gets the episode attributes' do
    eats = distribution.episode_attributes
    eats[:episode_number].must_equal 123
    eats[:season_number].must_equal 1
    eats[:clean_title].must_equal 'Clean Title'
  end

  it 'gets the episode attributes' do
    distribution.identifier_to_i('season 21').must_equal 21
    distribution.identifier_to_i('season 123:').must_equal 123
    distribution.identifier_to_i('season 1 episode 123').must_equal 123
  end

  it 'creates the episode on feeder' do
    podcast_distribution.stub(:get_account_token, 'token') do
      distribution.stub(:get_account_token, 'token') do
        distribution.url = nil
        distribution.wont_be :distributed?
        distribution.save!
        distribution.distribute!
        distribution.must_be :distributed?
        distribution.url.must_equal(episode_url)
      end
    end
  end

  it 'gets the episode' do
    distro = build(:episode_distribution, distribution: podcast_distribution, url: episode_url)
    podcast_distribution.stub(:get_account_token, 'token') do
      distro.stub(:get_account_token, 'token') do
        ep = distro.get_episode
        ep.title.must_equal 'Episode 1'
        ep.published_at.must_equal '2017-08-30T04:00:00.000Z'
      end
    end
  end

  it 'checks if the episode is published' do
    distro = build(:episode_distribution, distribution: podcast_distribution, url: episode_url)
    podcast_distribution.stub(:get_account_token, 'token') do
      distro.stub(:get_account_token, 'token') do
        distro.must_be :published?
      end
    end
  end
end
