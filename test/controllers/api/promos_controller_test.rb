require 'test_helper'

describe Api::PromosController do
  let(:user) { create(:user) }
  let(:story) { create(:story, account: user.individual_account) }

  it 'should show' do
    get :index, api_request_opts(story_id: story.id)
    assert_response :success
  end
end
