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

  before(:each) do
    feeder_importer_stub_import_requests
  end

  it 'makes a new importer' do
    importer.wont_be_nil
  end

  it 'retrieves the feeder podcast' do
    remote_podcast = importer.retrieve_podcast
    remote_podcast.wont_be_nil
    remote_podcast.title.must_equal 'Transistor'
  end

  it 'creates a series' do
    importer.podcast = podcast
    series = importer.create_series
    series.wont_be_nil
    series.title.must_equal 'Transistor'
    series.account_id.must_equal 8
    series.creator_id.must_equal 8
    series.short_description.must_match /^A podcast of scientific questions/
    series.description_html.must_match /^<p>Transistor is podcast of scientific curiosities/

    series.images.profile.wont_be_nil
    series.images.profile.upload.must_equal podcast.itunes_image['url']

    series.images.thumbnail.wont_be_nil
    series.images.thumbnail.upload.must_equal podcast.feed_image['url']

    series.audio_version_templates.size.must_equal 1
    series.audio_version_templates.first.audio_file_templates.size.must_equal 1

    series.distributions.size.must_equal 1
  end

  def feeder_importer_stub_import_requests
    stub_request(:post, 'https://id.prx.org/token').
      to_return(status: 200,
                body: '{"access_token":"thisisnotatoken","token_type":"bearer"}',
                headers: { 'Content-Type' => 'application/json; charset=utf-8' })

    stub_request(:get, 'https://feeder.prx.org/api/v1/podcasts/40').
      with(headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
      to_return(status: 200, body: json_file('transistor_podcast'), headers: {})

    stub_request(:get, "https://feeder.prx.org/api/v1/podcasts/40/episodes").
      with(headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
      to_return(status: 200, body: json_file('transistor_episodes'), headers: {})
  end
end
