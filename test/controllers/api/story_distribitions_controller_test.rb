require 'test_helper'

describe Api::StoryDistributionsController do

  let(:user) { create(:user) }
  let(:story_distribution) { create(:episode_distribution) }
  let(:distribution) { story_distribution.distribution }
  let(:story) { story_distribution.story }
  let(:token) { StubToken.new(story.account.id, ['cms:story'], user.id) }

  it 'should show' do
    get :show, api_request_opts(story_id: story.id, id: story_distribution.id)
    assert_response :success
  end

  before(:each) do
    class << @controller; attr_accessor :prx_auth_token; end
    @controller.prx_auth_token = token
  end

  describe '#create' do
    it 'can create an episode distribution for a story' do
      pd_hash = {
        kind: 'episode'
      }
      @request.env['CONTENT_TYPE'] = 'application/json'
      def @controller.after_create_resource(res)
        res.update_attributes!(url: 'http://feeder.prx.org/api/v1/episodes/thisisaguid')
      end
      post :create, pd_hash.to_json, api_request_opts(story_id: story.id)
      assert_response :success
      resource = JSON.parse(response.body)
      resource['_links']['prx:episode']['href'].must_equal 'http://feeder.prx.org/api/v1/episodes/thisisaguid'
    end
  end
end
