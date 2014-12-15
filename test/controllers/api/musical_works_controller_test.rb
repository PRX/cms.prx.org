require 'test_helper'

describe Api::MusicalWorksController do
  let(:user) { create(:user) }
  let(:story) { create(:story, account: user.individual_account) }
  let(:musical_work) { create(:musical_work, story: story) }

  it 'should show' do
    get(:show, { api_version: 'v1', format: 'json', story_id: story.id, id: musical_work.id } )
    assert_response :success
  end

  it 'should list' do
    musical_work.id.wont_be_nil
    get(:index, { api_version: 'v1', format: 'json', story_id: story.id } )
    assert_response :success
  end
end
