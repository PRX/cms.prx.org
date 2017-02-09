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
      with(headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
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

    stub_request(:post, 'https://cms.prx.org/api/v1/series/12345/audio_version_templates').
      with(body: '{"label":"Podcast Audio"}',
           headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
      to_return(status: 200, body: json_file('transistor_template'), headers: {})

    stub_request(:post, 'https://cms.prx.org/api/v1/audio_version_templates/172/audio_file_templates').
      with(body: '{"position":1,"label":"Segment 1"}',
           headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
      to_return(status: 200, body: json_file('transistor_file_template'), headers: {})

    stub_request(:post, 'https://cms.prx.org/api/v1/series/12345/distributions').
      with(body: '{"kind":"podcast"}',
           headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
      to_return(status: 200, body: json_file('podcast_distribution'), headers: {})

    stub_request(:get, 'https://feeder.prx.tech/api/v1/podcasts/51').
      with(headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
      to_return(status: 200, body: json_file('transistor_podcast'), headers: {})

    stub_request(:put, 'https://feeder.prx.tech/api/v1/podcasts/51').
      with(body: '{"id":51,"title":"Transistor","explicit":true}',
           headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
      to_return(status: 200, body: json_file('transistor_podcast'), headers: {})

    stub_request(:post, 'https://cms.prx.org/api/v1/series/12345/stories').
      with(body: '{"title":"test title"}',
           headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
      to_return(status: 200, body: json_file('transistor_story'), headers: {})

    stub_request(:post, "https://cms.prx.org/api/v1/stories/186929/audio_versions").
      with(body: '{"setAudioVersionTemplate":"/api/v1/audio_version_templates/172"}',
           headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
      to_return(status: 200, body: json_file('transistor_version'), headers: {})

    stub_request(:post, 'https://cms.prx.org/api/v1/audio_versions/400094/audio_files').
      with(body: '{"upload":"http://some.audio/file.mp3"}',
           headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
      to_return(status: 200, body: json_file('transistor_audio'), headers: {})

    stub_request(:post, 'https://cms.prx.org/api/v1/stories/186929/images').
      with(body: '{"upload":"http://some.image/file.png"}',
           headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
      to_return(status: 200, body: json_file('image'), headers: {})


    stub_request(:get, 'https://feeder.prx.tech/api/v1/episodes/153e6ea8-6485-4d53-9c22-bd996d0b3b03').
      with(headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
      to_return(status: 200, body: json_file('transistor_episode'), headers: {})

    stub_request(:put, "https://feeder.prx.tech/api/v1/episodes/153e6ea8-6485-4d53-9c22-bd996d0b3b03").
      with(body: '{"guid":"https://transistor.prx.org/?p=1286","title":"test title"}',
           headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
      to_return(status: 200, body: json_file('transistor_episode'), headers: {})

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

  let(:template) do
    api_resource(JSON.parse(json_file('transistor_template')), cms_root).tap do |r|
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
    importer.template = template
    stories = importer.create_stories(feed, series)
  end
end
