require 'test_helper'
require 'podcast_importer'
require 'prx_access'

describe PodcastImporter do
  include PRXAccess

  let(:account_path) { '/api/v1/accounts/8' }
  let(:podcast_url) { 'http://feeds.prx.org/transistor_stem' }
  let(:importer) { PodcastImporter.new(account_path, podcast_url) }

  before do
    stub_request(:get, podcast_url).
      to_return(status: 200, body: test_file('/fixtures/transistor.xml'), headers: {})


    stub_request(:post, 'https://id.prx.org/token').
      to_return(status: 200,
                body: '{"access_token":"thisisnotatoken","token_type":"bearer"}',
                headers: { 'Content-Type' => 'application/json; charset=utf-8' })

    stub_request(:get, 'https://cms.prx.org/api/v1').
      with(headers: { 'Authorization'=>'Bearer thisisnotatoken' }).
      to_return(status: 200, body: json_file('cms_root'), headers: {})

    stub_request(:post, 'https://cms.prx.org/api/v1/series/').
      with(body: '{"title":"Transistor","shortDescription":"A podcast of scientific questions and stories featuring guest hosts and reporters.","description":"A podcast of scientific questions and stories, with many episodes hosted by key scientists at the forefront of discovery."}',
           headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
      to_return(status: 200, body: json_file('transistor_series'), headers: {})

    stub_request(:post, 'https://cms.prx.org/api/v1/series/12345/images').
      with(body: '{"upload":"https://cdn-transistor.prx.org/wp-content/uploads/powerpress/transistor1400.jpg","purpose":"profile"}',
           headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
      to_return(status: 200, body: json_file('image'), headers: {})

    stub_request(:post, 'https://cms.prx.org/api/v1/series/12345/images').
      with(body: '{"upload":"http://cdn-transistor.prx.org/wp-content/uploads/powerpress/transistor300.png","purpose":"thumbnail"}',
           headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
      to_return(status: 200, body: json_file('image'), headers: {})

    stub_request(:post, 'https://cms.prx.org/api/v1/series/12345/distributions').
      with(body: '{"kind":"podcast"}',
           headers: { 'Content-Type' => 'application/json', 'Authorization' => 'Bearer thisisnotatoken' }).
      to_return(status: 200, body: json_file('podcast_distribution'), headers: {})

    stub_request(:get, 'https://feeder.prx.tech/api/v1/podcasts/51').
      with(headers: { 'Content-Type' => 'application/json', 'Authorization' => 'Bearer thisisnotatoken' }).
      to_return(status: 200, body: json_file('transistor_podcast'), headers: {})

    stub_request(:put, 'https://feeder.prx.tech/api/v1/podcasts/51').
      with(body: '{"id":51,"title":"Transistor","explicit":true}',
           headers: { 'Authorization' => 'Bearer thisisnotatoken', 'Content-Type' => 'application/json' }).
      to_return(status: 200, body: json_file('transistor_podcast'), headers: {})

    stub_request(:post, 'https://cms.prx.org/api/v1/series/12345/stories').
      with(body: '{"title":"test title"}',
           headers: { 'Authorization' => 'Bearer thisisnotatoken', 'Content-Type' => 'application/json' }).
      to_return(status: 200, body: '', headers: {})
  end

  let(:feed) { Feedjira::Feed.parse(test_file('/fixtures/transistor.xml')) }

  let(:series) do
    api_resource(JSON.parse(json_file('transistor_series')), cms_root).tap do |r|
      r.headers = r.headers.merge('Authorization' => 'Bearer thisisnotatoken')
    end
  end

  let(:distribution) do
    api_resource(JSON.parse(json_file('podcast_distribution')), cms_root).tap do |r|
      r.headers = r.headers.merge('Authorization' => 'Bearer thisisnotatoken')
    end
  end

  it 'retrieves the feed' do
    feed = importer.rss_feed
    feed.title.must_equal 'Transistor'
    feed.entries.count.must_equal 49
  end

  it 'creates a series' do
    series = importer.create_series(feed)
    series.attributes.title.must_equal 'Transistor'
  end

  it 'creates a podcast distribution' do
    distribution = importer.create_distribution(feed, series)
    distribution.links[:podcast].href.must_equal 'https://feeder.prx.tech/api/v1/podcasts/51'
  end

  it 'updates the podcast attributes' do
    podcast = importer.update_podcast(series, distribution)
    podcast.must_be :explicit
  end

  it 'creates the stories for the feed entries' do
    stories = importer.create_stories(feed, series)
  end
end
