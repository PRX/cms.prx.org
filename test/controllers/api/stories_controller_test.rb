# encoding: utf-8

require 'test_helper'

describe Api::StoriesController do
  let(:account) { create(:account) }
  let(:series) { create(:series, account: account) }
  let(:story) { create(:story, series: series) }

  before { Story.delete_all }

  describe 'editing' do
    let (:user) { create(:user) }
    let (:token) { StubToken.new(account.id, ['member'], user.id) }

    before(:each) do
      class << @controller; attr_accessor :prx_auth_token; end
      @controller.prx_auth_token = token
      @request.env['CONTENT_TYPE'] = 'application/json'

      # for `create`, feeder calls don't need to work, but webmock needs a response defined
      stub_request(:post, 'https://id.prx.org/token').to_return(status: 500)
    end

    it 'can create a new story' do
      story_hash = { title: 'create story', set_account_uri: "/api/v1/accounts/#{account.id}" }
      post :create, story_hash.to_json, api_version: 'v1', format: 'json'
      assert_response :success
    end

    it 'can create a new story with url parameters' do
      post :create,
           { title: 'story' }.to_json,
           api_version: 'v1',
           account_id: account.id
      assert_response :success
      id = JSON.parse(response.body)['id']
      Story.find(id).account_id.must_equal account.id
    end

    it 'can create a new story for a series' do
      post :create,
           { title: 'story' }.to_json,
           api_version: 'v1',
           series_id: series.id
      assert_response :success
      id = JSON.parse(response.body)['id']
      Story.find(id).account_id.must_equal account.id
    end

    it 'can create a new story for a series' do
      post :create,
           { title: 'story', set_series_uri: "/api/v1/series/#{series.id}" }.to_json,
           api_version: 'v1'
      assert_response :success
      id = JSON.parse(response.body)['id']
      Story.find(id).account_id.must_equal account.id
    end

    it 'can create a new story and distributions' do
      series.wont_be_nil
      story_hash = {
        title: 'create story',
        set_account_uri: "/api/v1/accounts/#{account.id}",
        set_series_uri: "/api/v1/series/#{series.id}"
      }
      post :create, story_hash.to_json, api_version: 'v1', format: 'json'
      assert_response :success
      res = JSON.parse(response.body)
      Story.find(res['id']).distributions.count.must_equal 1
    end

    it 'can set description as markdown' do
      story_hash = {
        title: 'story',
        description: '_description_'
      }
      post :create, story_hash.to_json, api_request_opts(account_id: account.id)
      assert_response :success
      res = JSON.parse(response.body)
      res['description'].must_equal "<p><em>description</em></p>"
      res['descriptionMd'].must_equal '_description_'
    end

    it 'can set description_md' do
      story_hash = {
        title: 'story',
        'descriptionMd' => '_description_'
      }
      post :create, story_hash.to_json, api_request_opts(account_id: account.id)
      assert_response :success
      res = JSON.parse(response.body)
      res['description'].must_equal "<p><em>description</em></p>"
      res['descriptionMd'].must_equal '_description_'
    end

    it 'returns descriptionMd for v3 stories' do
      story_v3 = create(:story_v3, description: "<p><em>description</em></p>")
      get(:show, api_request_opts(id: story_v3.id))
      assert_response :success
      res = JSON.parse(response.body)
      res['descriptionMd'].must_equal "_description_"
    end

    it 'rejects new stories with an invalid account' do
      new_account = create(:account)
      post :create,
           { title: 'story' }.to_json,
           api_version: 'v1',
           account_id: new_account.id
      response.status.must_equal 401
    end

    it 'can update a story' do
      story = create(:story, title: 'not this', account: account)
      put :update,
          { title: 'this' }.to_json,
          api_version: 'v1',
          format: 'json',
          id: story.id
      assert_response :success
      JSON.parse(response.body)['title'].must_equal('this')
    end

    it 'can publish a story' do
      story = create(:story,
                     title: 'not this',
                     account: account,
                     published_at: nil)
      post :publish, api_version: 'v1', format: 'json', id: story.id
      assert_response :success
      Story.find(story.id).published_at.wont_be_nil
    end

    it 'can unpublish a story' do
      story = create(:story,
                     title: 'not this',
                     account: account)
      post :unpublish, api_version: 'v1', format: 'json', id: story.id
      assert_response :success
      Story.find(story.id).published_at.must_be_nil
    end

    it 'can delete a story' do
      story = create(:story, account: account)
      delete :destroy, api_version: 'v1', format: 'json', id: story.id
      response.status.must_equal 204
      Story.where(id: story.id).must_be :empty?
    end
  end

  it 'should show' do
    get(:show, { api_version: 'v1', format: 'json', id: story.id } )
    assert_response :success
  end

  it 'should list published stories of any app version' do
    story1 = create(:story, published_at: 1.day.ago)
    story2 = create(:story, published_at: nil)
    story3 = create(:story_v3, published_at: 1.day.ago)

    get(:index, { api_version: 'v1', format: 'json' } )
    assert_response :success
    assigns[:stories].must_include story1
    assigns[:stories].wont_include story2
    assigns[:stories].must_include story3
  end

  it 'should list stories for an account' do
    story.must_be :published
    get(:index, api_version: 'v1',
                format: 'json',
                account_id: story.account_id)
    assert_response :success
  end

  it 'should list highlighted stories' do
    portfolio = create(:portfolio)
    playlist_section = create(:playlist_section, playlist: portfolio)
    pick1 = create(:pick, story: story, playlist_section: playlist_section)
    pick2 = create(:pick)

    get(:index, api_version: 'v1',
                format: 'json',
                account_id: portfolio.account_id,
                filters: 'highlighted')

    assert_response :success
    assert_not_nil assigns[:stories]
    assigns[:stories].must_include story
    assigns[:stories].wont_include pick2.story
  end

  it 'should list purchased stories' do
    create_list(:purchase, 3, purchased: story)
    story2 = create(:story, account: story.account)
    story3 = create(:story_with_purchases, account: story.account)

    get(:index, api_version: 'v1',
                format: 'json',
                account_id: story.account_id,
                filters: 'purchased')

    assert_response :success
    assert_not_nil assigns[:stories]
    assigns[:stories].must_include story
    assigns[:stories].must_include story3
    assigns[:stories].wont_include story2
  end

  it 'should list only v4 stories' do
    story1 = create(:story)
    story1.must_be :v4?
    story2 = create(:story_v3)
    get(:index, api_version: 'v1', format: 'json', filters: 'v4')
    assert_response :success
    assert_not_nil assigns[:stories]
    assigns[:stories].must_include story1
    assigns[:stories].wont_include story2
  end

  it 'should error on bad version' do
    get(:index, { api_version: 'v2', format: 'json' } )
    assert_response :not_acceptable
  end

  it 'should get a random story' do
    story.published_at = Time.now

    get(:random, api_version: 'v1', format: 'json')

    assert_response :success
    assert_not_nil assigns[:story]
  end

  it 'should list matching stories for text' do
    story = create(:story, title: 'You are all Weirdos')
    story2 = create(:story, title: 'We are all Freakazoids')
    get(:index, api_version: 'v1', format: 'json', filters: 'text=weirdos')
    assert_response :success
    assert_not_nil assigns[:stories]
    assigns[:stories].must_include story
    assigns[:stories].wont_include story2
  end
end
