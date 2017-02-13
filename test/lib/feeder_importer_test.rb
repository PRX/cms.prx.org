require 'test_helper'
require 'feeder_importer'
require 'prx_access'

describe FeederImporter do
  include PRXAccess
  let(:account_path) { '/api/v1/accounts/8' }
  let(:feeder_path) { '/api/v1/podcasts/23' }
  let(:importer) { FeederImporter.new(account_path, feeder_path) }

  before do
    stub_request(:get, 'http://feeder.prx.tech/api/v1/podcasts/23').
      with(headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
      to_return(status: 200, body: json_file('99pi'), headers: {})

    stub_request(:get, 'https://cms.prx.org/api/v1').
      with(headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
      to_return(status: 200, body: json_file('cms_root'), headers: {})

    stub_request(:post, 'https://cms.prx.org/api/v1/series/').
      with(body: '{"title":"99% Invisible","short_description":"A tiny radio show about design, architecture & the 99% invisible activity that shapes our world.","description":"Design is everywhere in our lives, perhaps most importantly in the places where we’ve just stopped noticing. 99% Invisible is a weekly exploration of the process and power of design and architecture. From award winning producer Roman Mars. Learn more at <a href="http://99percentinvisible.org">99percentinvisible.org</a>.<br/> A proud member of Radiotopia, from PRX. Learn more at <a href="http://radiotopia.fm/">radiotopia.fm</a>."}',
           headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
      to_return(status: 200, body: json_file('99pi_series'), headers: {})

    stub_request(:post, 'https://cms.prx.org/api/v1/series/12345/image').
      with(body: '{"upload":"http://cdn-99percentinvisible.prx.org/99-1400.png"}',
           headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
      to_return(status: 200, body: json_file('image'), headers: {})

    stub_request(:get, 'http://cms.prx.org/api/v1/series/12345/distributions').
      with(headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
      to_return(status: 200, body: json_file('distributions_empty'), headers: {})

    stub_request(:post, 'http://cms.prx.org/api/v1/series/12345/distributions').
      with(body: '{"kind":"podcast","url":"http://feeder.prx.tech/api/v1/podcasts/23"}',
           headers: { 'Authorization' => 'Bearer thisisnotatoken' }).
      to_return(status: 200, body: json_file('podcast_distribution'), headers: {})
  end

  # it 'importer has account and feed' do
  #   importer.feeder_podcast_path.must_equal feeder_path
  #   importer.cms_account_path.must_equal account_path
  # end
  #
  # it 'can retrieve the podcast from feeder' do
  #   importer.stub(:get_account_token, 'thisisnotatoken') do
  #     podcast = importer.get_feeder_podcast(feeder_path)
  #     podcast.wont_be_nil
  #   end
  # end
  #
  # it 'creates a series based on a feeder podcast' do
  #   podcast = api_resource(JSON.parse(json_file('99pi')), 'http://feeder.prx.tech/api/v1')
  #   importer.stub(:get_account_token, 'thisisnotatoken') do
  #     series = importer.create_series(podcast)
  #     series.wont_be_nil
  #   end
  # end
  #
  # it 'creates a podcast distribution' do
  #   podcast = api_resource(JSON.parse(json_file('99pi')), 'http://feeder.prx.tech/api/v1')
  #   series = api_resource(JSON.parse(json_file('99pi_series')), 'http://cms.prx.org/api/v1')
  #   importer.stub(:get_account_token, 'thisisnotatoken') do
  #     series = importer.create_distribution(podcast, series)
  #     series.wont_be_nil
  #   end
  # end
end
