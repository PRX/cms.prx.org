require 'test_helper'

describe Distributions::PodcastDistribution do

  let(:distribution) { build(:podcast_distribution) }
  let(:podcast_url) { URI.join(distribution.feeder_root, '/api/v1/podcasts/23').to_s }

  before do
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
  end

  it 'creates the podcast on feeder' do
    distribution.stub(:get_account_token, 'fail') do
      distribution.url = nil
      distribution.account.wont_be_nil
      distribution.save!
      -> do
        distribution.distribute!
      end.must_raise(HyperResource::ServerError)
    end
  end

  it 'throws error and rolls back if podcast on feeder fails' do
    distribution.stub(:get_account_token, 'token') do
      distribution.url = nil
      distribution.account.wont_be_nil
      distribution.save!
      distribution.distribute!
      distribution.url.must_equal(podcast_url)
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
    attrs.keys.count.must_equal 7
    attrs[:prx_uri].must_equal "/api/v1/series/#{distribution.owner.id}"
    attrs[:prx_account_uri].must_equal "/api/v1/accounts/#{distribution.account.id}"
    attrs[:published_at].wont_be_nil
  end
end
