require 'test_helper'

describe Api::Auth::EpisodeImportsController do

  let (:user) { create(:user) }
  let (:token) { StubToken.new(account.id, ['member'], user.id) }
  let (:account) { user.individual_account }
  let (:podcast_import) { create(:podcast_import, account: account) }
  let (:episode_import) { create(:episode_import, podcast_import: podcast_import) }

  around do |test|
    @controller.stub(:prx_auth_token, token) { test.call }
  end

  it 'should show' do
    episode_import.id.wont_be_nil
    get :show, api_request_opts(podcast_import_id: podcast_import.id, id: episode_import.id)
    assert_response :success
  end

  it 'should handle routes for the episode import placeholders' do
    pth = api_authorization_podcast_import_episode_import_placeholders_path(1)
    hsh = Rails.application.routes.recognize_path(pth)

    hsh.must_equal({api_version: 'v1',
                    controller: 'api/auth/episode_imports',
                    action: 'index',
                    podcast_import_id: '1'})
  end
end
