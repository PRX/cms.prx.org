require 'test_helper'

describe Api::Auth::StoriesController do
  let (:user) { create(:user) }
  let (:token) { StubToken.new(account.id, ['member'], user.id) }
  let (:account) { user.individual_account }
  let (:unpublished_story) { account.stories.first }
  let (:published_story) { account.stories.last }
  let (:latest_story) { create(:story, account: user.individual_account) }
  let (:unpublished_story) { account.stories.first }
  let (:random_story) { create(:story, published_at: nil) }
  let (:network) { create(:network, account: user.individual_account) }
  let (:network_story) { create(:story, network_id: network.id, network_only_at: Time.now) }
  let (:v3_story) { create(:story_v3, account: account) }

  before do
    account.stories.each { |s| s }
    unpublished_story.update!(published_at: nil)
    published_story.update_attributes!(published_at: 2.days.ago)
    latest_story.update_attributes!(published_at: 1.day.ago)
  end

  describe 'with a valid token' do
    around do |test|
      @controller.stub(:prx_auth_token, token) { test.call }
    end

    it 'indexes stories under their account' do
      get(:index, api_version: 'v1', account_id: account.id)
      assert_response :success
      JSON.parse(response.body)['count'].must_equal account.stories.count
      account.stories.count.must_be :>, account.public_stories.count
    end

    it 'indexes stories with unpublished first, recently published after' do
      published_story.published_at.must_be :<, latest_story.published_at
      get(:index, api_request_opts(account_id: account.id, sorts: 'published_at:desc'))
      assert_response :success
      assigns[:stories][0].wont_be :published?
      assigns[:stories][1].published_at.must_be :>, assigns[:stories][2].published_at
    end

    it 'indexes stories with unpublished first, oldest published after' do
      published_story.published_at.must_be :<, latest_story.published_at
      get(:index, api_request_opts(account_id: account.id, sorts: 'published_at:asc'))
      assert_response :success
      assigns[:stories][0].wont_be :published?
      assigns[:stories][1].published_at.must_be :<, assigns[:stories][2].published_at
    end

    it 'indexes stories in a network' do
      get(:index, api_version: 'v1', network_id: network.id)
      assert_response :success
      JSON.parse(response.body)['count'].must_equal network.stories.count
    end

    it 'filters v4 stories' do
      unpublished_story.must_be :v4?
      v3_story.wont_be :v4?
      get(:index, api_version: 'v1', format: 'json', filters: 'v4')
      assert_response :success
      assert_not_nil assigns[:stories]
      assigns[:stories].must_include unpublished_story
      assigns[:stories].wont_include v3_story
    end

    it 'applies multiple filters' do
      create(:series, stories: [unpublished_story])
      unpublished_story.series.wont_be_nil
      v3_story.wont_be :v4?
      v3_story.series.must_be_nil

      get(:index, api_version: 'v1', filters: 'v4,noseries')
      assert_response :success
      assert_not_nil assigns[:stories]
      assigns[:stories].wont_include unpublished_story
      assigns[:stories].wont_include v3_story
    end

    it 'error for network user access' do
      other_network = create(:network)
      get(:index, api_version: 'v1', network_id: other_network.id)
      assert_response :unauthorized
    end

    it 'shows an unpublished story' do
      get(:show, api_version: 'v1', id: unpublished_story.id)
      assert_response :success
    end

    it 'creates a story' do
      @request.env['CONTENT_TYPE'] = 'application/json'
      post :create, { title: 'foobar' }.to_json, api_version: 'v1', account_id: account.id
      assert_response :success
      story = Story.find(JSON.parse(response.body)['id'])
      story.title.must_equal 'foobar'
      story.published_at.must_be_nil
      story.account_id.must_equal account.id
    end

    it 'updates an unpublished story' do
      @request.env['CONTENT_TYPE'] = 'application/json'
      put :update, { title: 'foobar' }.to_json, api_version: 'v1', id: unpublished_story.id
      assert_response :success
      Story.find(unpublished_story.id).title.must_equal('foobar')
    end

    it 'deletes an unpublished story' do
      story = create(:story, account: account, published_at: nil)
      delete :destroy, api_version: 'v1', id: story.id
      response.status.must_equal 204
      Story.where(id: story.id).must_be :empty?
    end

    it 'does not show unowned stories' do
      get(:show, api_version: 'v1', id: random_story.id)
      assert_response :not_found
    end

    it 'does not update unowned stories' do
      @request.env['CONTENT_TYPE'] = 'application/json'
      put :update, { title: 'foobar' }.to_json, api_version: 'v1', id: random_story.id
      assert_response :not_found
    end

    it 'does not delete unowned stories' do
      delete :destroy, api_version: 'v1', id: random_story.id
      assert_response :not_found
    end
  end

  describe 'with no token' do
    it 'will not show you anything' do
      get(:show, api_version: 'v1', id: unpublished_story.id)
      assert_response :unauthorized
    end

    it 'will not index you anything' do
      get(:index, api_version: 'v1', account_id: account.id)
      assert_response :unauthorized
    end
  end
end
