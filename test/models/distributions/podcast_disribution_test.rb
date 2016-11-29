require 'test_helper'

describe Distributions::PodcastDistribution do

  let(:distribution) { create(:podcast_distribution) }

  it 'creates the podcast on feeder' do
    stub_request(:get, "http://feeder.docker/api/v1").
      with(:headers => {'Accept'=>'application/json', 'Authorization'=>'Bearer token', 'Content-Type'=>'application/json'}).
      to_return(:status => 200, :body => json_file('feeder_root'))

    stub_request(:post, "http://feeder.docker/api/v1/podcasts").
      with(:headers => {'Authorization'=>'Bearer token', 'Content-Type'=>'application/json'}).
      to_return(:status => 200, :body => json_file('podcast'), :headers => {})

    distribution.stub(:get_account_token, "token") do
      distribution.account.wont_be_nil
      distribution.add_podcast_to_feeder
      distribution.url.must_equal(URI.join(distribution.feeder_root, "/api/v1/podcasts/23").to_s)
    end
  end

  it 'returns attributes for creating the podcast' do
    attrs = distribution.podcast_attributes
    attrs.keys.count.must_equal 2
    attrs[:prx_uri].must_equal "/api/v1/series/#{distribution.owner.id}"
    attrs[:prx_account_uri].must_equal "/api/v1/accounts/#{distribution.account.id}"
  end
end
