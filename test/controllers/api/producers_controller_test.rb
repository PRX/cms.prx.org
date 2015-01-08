require 'test_helper'

describe Api::ProducersController do

  let(:user) { create(:user) }
  let(:story) { create(:story, account: user.individual_account) }
  let(:producer) { create(:producer, story: story) }

  it 'should show' do
    get :show, api_request_opts(story_id: story.id, id: producer.id)
    assert_response :success
  end

  it 'should list' do
    producer.id.wont_be_nil
    get :index, api_request_opts(story_id: story.id)
    assert_response :success
  end
end
