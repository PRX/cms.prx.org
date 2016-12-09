require 'test_helper'

describe Api::StoryDistributionsController do

  let(:story_distribution) { create(:episode_distribution) }
  let(:distribution) { story_distribution.distribution }
  let(:story) { story_distribution.story }
  let(:token) { StubToken.new(account.id, ['member']) }

  it 'should show' do
    get :show, api_request_opts(story_id: story.id, id: story_distribution.id)
    assert_response :success
  end

  # before(:each) do
  #   class << @controller; attr_accessor :prx_auth_token; end
  #   @controller.prx_auth_token = token
  # end
  #
  # describe '#create' do
  #   it 'can create a podcast distribution for a series' do
  #     pd_hash = {
  #       kind: 'podcast'
  #     }
  #     @request.env['CONTENT_TYPE'] = 'application/json'
  #     def @controller.distribute(res)
  #       res.update_column(:url, 'http://feeder.prx.org/api/v1/podcast/12345')
  #     end
  #     post :create, pd_hash.to_json, api_request_opts(series_id: series.id)
  #     assert_response :success
  #     resource = JSON.parse(response.body)
  #     resource['_links']['prx:podcast']['href'].must_equal 'http://feeder.prx.org/api/v1/podcast/12345'
  #   end
  # end
end
