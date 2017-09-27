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
  end

  it 'gets the episode attributes' do
    eats = distribution.episode_attributes
    eats[:episode_identifier].must_equal 123
    eats[:season_identifier].must_equal 1
  end

  it 'gets the episode attributes' do
    distribution.identifier_to_i("season 21").must_equal 21
    distribution.identifier_to_i("season 123:").must_equal 123
    distribution.identifier_to_i("season 1 episode 123").must_equal 123
  end

  it 'creates the episode on feeder' do
    podcast_distribution.stub(:get_account_token, 'token') do
      distribution.stub(:get_account_token, 'token') do
        distribution.url = nil
        distribution.save!
        distribution.distribute!
        distribution.url.must_equal(episode_url)
      end
    end
  end
end
