require 'test_helper'
require 'feeder_importer'
require 'prx_access'

describe FeederImporter do
  include PRXAccess

  let(:account_id) { 8 }
  let(:user_id) { 8 }
  let(:feeder_podcast_url) { 'https://feeder.prx.org/api/v1/podcasts/40' }
  let(:importer) { FeederImporter.new(account_id, user_id, feeder_podcast_url) }

  let(:podcast) do
    api_resource(JSON.parse(json_file('transistor_podcast')), feeder_root).tap do |r|
      r.headers = r.headers.merge('Authorization' => 'Bearer thisisnotatoken')
    end
  end

  before do
    stub_import_requests
  end


  it "makes a new importer" do
    importer.wont_be_nil
  end

  it "retrieves the feeder podcast" do
    podcast = importer.retrieve_podcast
    podcast.wont_be_nil
    podcast.title.must_equal 'Transistor'
  end

  it "creates a series" do
    importer.podcast = podcast
    series = importer.create_series
    series.wont_be_nil
    series.title.must_equal 'Transistor'
    series.account_id.must_equal 8
    series.creator_id.must_equal 8
    series.short_description.must_match /^A podcast of scientific questions/
    series.description.must_match /^<p>Transistor is podcast of scientific curiosities/
  end
end

def stub_import_requests
  stub_request(:post, 'https://id.prx.org/token').
    to_return(status: 200,
              body: '{"access_token":"thisisnotatoken","token_type":"bearer"}',
              headers: { 'Content-Type' => 'application/json; charset=utf-8' })

  stub_request(:get, 'https://feeder.prx.org/api/v1/podcasts/40').
    with(headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
    to_return(status: 200, body: json_file('transistor_podcast'), headers: {})
end
