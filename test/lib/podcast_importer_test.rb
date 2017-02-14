require 'test_helper'
require 'podcast_importer'
require 'prx_access'

describe PodcastImporter do
  include PRXAccess

  let(:account_path) { '/api/v1/accounts/8' }
  let(:podcast_url) { 'http://feeds.prx.org/transistor_stem' }
  let(:importer) { PodcastImporter.new(account_path, podcast_url) }

  before do
    stub_requests
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

  describe 'import' do
    it 'retrieves the feed' do
      feed = importer.rss_feed
      feed.title.must_equal 'Transistor'
      feed.entries.count.must_equal 1
    end

    it 'creates a series' do
      series, template = importer.create_series(feed)
      series.attributes.title.must_equal 'Transistor'
      template.wont_be_nil
    end

    it 'creates a podcast distribution' do
      distribution = importer.create_distribution(series, template)
      distribution.links[:podcast].href.must_equal 'https://feeder.prx.tech/api/v1/podcasts/51'
    end

    it 'updates the podcast attributes' do
      podcast = importer.update_podcast(distribution, feed)
      podcast.must_be :explicit
    end

    it 'creates the stories for the feed entries' do
      importer.template = template
      stories = importer.create_stories(feed, series)
      stories.wont_be_nil
      stories.count.must_equal 1
    end

    it 'imports a podcast' do
      importer.import.must_equal true
      importer.series.wont_be_nil
      importer.stories.count.must_equal 1
    end
  end
end

def stub_requests
  stub_request(:get, 'http://feeds.prx.org/transistor_stem').
    to_return(status: 200, body: test_file('/fixtures/transistor.xml'), headers: {})

  stub_request(:post, 'https://id.prx.org/token').
    to_return(status: 200,
              body: '{"access_token":"thisisnotatoken","token_type":"bearer"}',
              headers: { 'Content-Type' => 'application/json; charset=utf-8' })

  stub_request(:get, 'https://cms.prx.org/api/v1/accounts/8').
    with(headers: { 'Authorization'=>'Bearer thisisnotatoken' }).
    to_return(status: 200, body: json_file('account'), headers: {})

  stub_request(:post, 'https://cms.prx.org/api/v1/accounts/8/series').
    with(body: '{"title":"Transistor","shortDescription":' +
               '"A podcast of scientific questions and stories featuring guest hosts and ' +
               'reporters.","description":"A podcast of scientific questions and stories, ' +
               'with many episodes hosted by key scientists at the forefront of discovery."}',
         headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
    to_return(status: 200, body: json_file('transistor_series'), headers: {})

  stub_request(:post, 'https://cms.prx.org/api/v1/series/12345/images').
    with(body: '{"upload":"https://cdn-transistor.prx.org/transistor1400.jpg","purpose":"profile"}',
         headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
    to_return(status: 200, body: json_file('image'), headers: {})

  stub_request(:post, 'https://cms.prx.org/api/v1/series/12345/images').
    with(body: '{"upload":"http://cdn-transistor.prx.org/transistor300.png","purpose":"thumbnail"}',
         headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
    to_return(status: 200, body: json_file('image'), headers: {})

  stub_request(:post, 'https://cms.prx.org/api/v1/series/12345/audio_version_templates').
    with(body: '{"label":"Podcast Audio","explicit":"clean","promos":false,' +
               '"lengthMinimum":0,"lengthMaximum":0}',
         headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
    to_return(status: 200, body: json_file('transistor_template'), headers: {})

  stub_request(:post, 'https://cms.prx.org/api/v1/audio_version_templates/172/audio_file_templates').
    with(body: '{"position":1,"label":"Segment A","lengthMinimum":0,"lengthMaximum":0}',
         headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
    to_return(status: 200, body: json_file('transistor_file_template'), headers: {})

  stub_request(:post, 'https://cms.prx.org/api/v1/series/12345/distributions').
    with(body: '{"kind":"podcast","setAudioVersionTemplate":"/api/v1/audio_version_templates/172"}',
         headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
    to_return(status: 200, body: json_file('podcast_distribution'), headers: {})

  stub_request(:get, 'https://feeder.prx.tech/api/v1/podcasts/51').
    with(headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
    to_return(status: 200, body: json_file('transistor_podcast'), headers: {})

  stub_request(:put, 'https://feeder.prx.tech/api/v1/podcasts/51').
    with(body: '{"id":51,"title":"Transistor","copyright":"Copyright 2016 PRX",' +
               '"language":"en-US","updateFrequency":"1","updatePeriod":"hourly",' +
               '"link":"https://transistor.prx.org","explicit":"clean",' +
               '"newFeedUrl":"http://feeds.prx.org/transistor_stem","path":"transistor_stem",' +
               '"author":{"name":"PRX","email":null},' +
               '"managingEditor":{"name":"PRX","email":"prxwpadmin@prx.org"},' +
               '"owners":[{"name":"PRX","email":"prxwpadmin@prx.org"}],' +
               '"itunesCategories":[{"name":"Science & Medicine","subcategories":["Natural Sciences"]}],' +
               '"categories":[],"complete":false,"keywords":[]}',
    headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
    to_return(status: 200, body: json_file('transistor_podcast'), headers: {})

  stub_request(:post, 'https://cms.prx.org/api/v1/series/12345/stories').
    with(body: '{"title":"Sidedoor from the Smithsonian: Shake it Up",' +
               '"shortDescription":"An astronomer has turned the night sky into a symphony.",' +
               '"description":"For the next few episodes, we’re featuring the ' +
               'Smithsonian’s new series, Sidedoor, about where science, art, history, and ' +
               'humanity unexpectedly overlap — just like in their museums. In this episode: ' +
               'an astronomer has turned the night sky into a symphony; an architecture firm ' +
               'has radically re-thought police stations; and an audiophile builds a successful ' +
               'record … <a href=\"https://transistor.prx.org/2017/01/sidedoor-from-the-' +
               'smithsonian-shake-it-up/\" class=\"more-link\">Continue reading <span class=' +
               '\"screen-reader-text\">Sidedoor from the Smithsonian: Shake it Up</span></a>",' +
               '"tags":["Indie Features"],"releasedAt":"2017-01-20T03:04:12.000Z"}',
         headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
    to_return(status: 200, body: json_file('transistor_story'), headers: {})

  stub_request(:post, 'https://cms.prx.org/api/v1/stories/186929/audio_versions').
    with(body: '{"setAudioVersionTemplate":"/api/v1/audio_version_templates/172",' +
               '"label":"Podcast Audio","explicit":null}',
         headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
    to_return(status: 200, body: json_file('transistor_version'), headers: {})

  stub_request(:post, 'https://cms.prx.org/api/v1/audio_versions/400094/audio_files').
    with(body: '{"upload":"https://dts.podtrac.com/redirect.mp3/media.blubrry.com/transistor' +
               '/cdn-transistor.prx.org/wp-content/uploads/Smithsonian3_Transistor.mp3"}',
         headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
    to_return(status: 200, body: json_file('transistor_audio'), headers: {})

  stub_request(:post, 'https://cms.prx.org/api/v1/stories/186929/images').
    with(body: '{"upload":"https://cdn-transistor.prx.org/shake.jpg"}',
         headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
    to_return(status: 200, body: json_file('image'), headers: {})

  stub_request(:get, 'https://cms.prx.org/api/v1/stories/186929/story_distributions').
    with(headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
    to_return(status: 200, body: json_file('transistor_distributions'), headers: {})

  stub_request(:put, 'https://cms.prx.org/api/v1/stories/186929/story_distributions/82').
    with(body: '{"kind":"episode","id":82,"url":' +
               '"https://feeder.prx.tech/api/v1/episodes/153e6ea8-6485-4d53-9c22-bd996d0b3b03",' +
               '"guid":"https://transistor.prx.org/?p=1286"}',
         headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
    to_return(status: 200, body: json_file('transistor_distribution'), headers: {})

  stub_request(:get, 'https://feeder.prx.tech/api/v1/episodes/153e6ea8-6485-4d53-9c22-bd996d0b3b03').
    with(headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
    to_return(status: 200, body: json_file('transistor_episode'), headers: {})

  stub_request(:put, 'https://feeder.prx.tech/api/v1/episodes/153e6ea8-6485-4d53-9c22-bd996d0b3b03').
    with(body: '{"guid":"https://transistor.prx.org/?p=1286","title":"Sidedoor from the ' +
               'Smithsonian: Shake it Up","author":{"name":"PRX","email":null},' +
               '"block":false,"explicit":null,"isClosedCaptioned":false,"isPermaLink":"false",' +
               '"keywords":[],"position":null,"url":' +
               '"https://transistor.prx.org/2017/01/sidedoor-from-the-smithsonian-shake-it-up/"}',
         headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
    to_return(status: 200, body: json_file('transistor_episode'), headers: {})
end
