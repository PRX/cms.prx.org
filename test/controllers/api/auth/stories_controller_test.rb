require 'test_helper'

describe Api::Auth::StoriesController do

  let (:user) { create(:user) }
  let (:token) { StubToken.new(account.id, ['member'], user.id) }
  let (:account) { user.individual_account }
  let (:unpublished_story) { account.all_stories.first }
  let (:random_story) { create(:story, published_at: nil) }

  before do
    unpublished_story.update!(published_at: nil)
  end

  describe 'with a valid token' do

    around do |test|
      @controller.stub(:prx_auth_token, token) { test.call }
    end

    it 'indexes stories under their account' do
      get(:index, api_version: 'v1', account_id: account.id)
      assert_response :success
      JSON.parse(response.body)['count'].must_equal account.all_stories.count
      account.all_stories.count.must_be :>, account.stories.count
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
      assert_response :no_content # TODO: see hal_actions.rb
    end

    it 'does not delete unowned stories' do
      delete :destroy, api_version: 'v1', id: random_story.id
      assert_response :no_content # TODO: see hal_actions.rb
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
