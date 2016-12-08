# encoding: utf-8

require 'test_helper'
require 'api/distributions/podcast_distribution_representer'

describe Api::Distributions::PodcastDistributionRepresenter do

  let(:distribution) { build(:podcast_distribution) }
  let(:representer)   { Api::Distributions::PodcastDistributionRepresenter.new(distribution) }
  let(:json)          { JSON.parse(representer.to_json) }

  before do
    stub_request(:get, "http://feeder.docker/api/v1").
      with(:headers => {'Accept'=>'application/json', 'Authorization'=>'Bearer token', 'Content-Type'=>'application/json'}).
      to_return(:status => 200, :body => json_file('feeder_root'))

    stub_request(:post, "http://feeder.docker/api/v1/podcasts").
      with(:headers => {'Authorization'=>'Bearer token', 'Content-Type'=>'application/json'}).
      to_return(:status => 200, :body => json_file('podcast'), :headers => {})

    distribution.stub(:get_account_token, "token") do
      distribution.save!
    end
  end

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal distribution.id
    json['properties']['explicit'].must_equal 'clean'
  end
end
