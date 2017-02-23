require 'test_helper'

describe Api::Auth::PodcastImportsController do

  let (:user) { create(:user) }
  let (:token) { StubToken.new(account.id, ['member'], user.id) }
  let (:account) { user.individual_account }
  let (:podcast_url) { 'http://feeds.prx.org/transistor_stem' }

  around do |test|
    @controller.stub(:prx_auth_token, token) { test.call }
  end

  it 'creates an import' do
    @request.env['CONTENT_TYPE'] = 'application/json'
    @controller.stub(:after_create_resource, true) do
      post :create, { url: podcast_url }.to_json, api_version: 'v1', account_id: account.id
    end
    assert_response :success
  end
end
