require 'test_helper'

describe Api::PromosController do
  let(:user) { create(:user) }
  let(:story) { create(:story, account: user.individual_account) }

  around { |test| @controller.stub(:current_user, true) { test.call } }

  it 'should show' do
    get :index, api_request_opts(story_id: story.id)
    assert_response :success
  end
end
