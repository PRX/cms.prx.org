require 'test_helper'

describe Api::Auth::PodcastImportsController do

  let (:user) { create(:user) }
  let (:token) { StubToken.new(account.id, ['member'], user.id) }
  let (:account) { user.individual_account }
  let (:podcast_url) { 'http://feeds.prx.org/transistor_stem' }
  let (:podcast_import) { create(:podcast_import, account: account) }

  let(:rss_feed_response) { test_file('/fixtures/transistor_two.xml') }

  around do |test|
    @controller.stub(:prx_auth_token, token) { test.call }
  end

  before do
    @request.env['CONTENT_TYPE'] = 'application/json'
    stub_request(:get, 'http://feeds.prx.org/transistor_stem').
      with(headers: {'Host' => 'feeds.prx.org', 'User-Agent'=> 'PRX CMS FeedValidator'}).
      to_return(status: 200, body: rss_feed_response, headers: {})
  end

  it 'should show' do
    podcast_import.id.wont_be_nil
    get :show, api_request_opts(id: podcast_import.id)
    assert_response :success
  end

  it 'creates an import' do
    @controller.stub(:after_create_resource, true) do
      post :create, { url: podcast_url }.to_json, api_version: 'v1', account_id: account.id
    end
    assert_response :success
  end

  it 'immediately creates an associated series' do
    assert_difference('Series.count', 1) do
      assert_difference('PodcastImport.count', 1) do
        post :create, { url: podcast_url }.to_json, api_version: 'v1', account_id: account.id
      end
    end
    assert_response :success
  end

  it 'should rollback if there is an error with the import prelude' do
    podcast_import = PodcastImport.new
    raiser = lambda { raise }
    podcast_import.stub(:import_prelude, raiser) do
      @controller.stub(:create_resource, podcast_import) do
        assert_difference('Series.count', 0) do
          assert_difference('PodcastImport.count', 0) do
            post :create, { url: podcast_url }.to_json, api_version: 'v1', account_id: account.id
          end
        end
      end
    end
  end
end
