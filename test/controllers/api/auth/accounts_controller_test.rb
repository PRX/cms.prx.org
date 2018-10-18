require 'test_helper'

describe Api::Auth::AccountsController do

  let (:user) { create(:user_with_accounts, group_accounts: 2) }
  let (:user_without_account) { create(:user, with_individual_account: false) }
  let (:individual_account) { user.individual_account }
  let (:member_account) { create(:account) }
  let (:unapproved_account) { create(:account) }
  let (:token) { StubToken.new(nil, nil, user.id) }

  before do
    token.authorized_resources = {
      member_account.id => 'member',
      individual_account.id => 'admin'
    }
  end

  describe 'with a valid token' do

    around do |test|
      @request.env['CONTENT_TYPE'] = 'application/json'
      @controller.stub(:prx_auth_token, token) { test.call }
    end

    it 'shows individual account' do
      get(:show, api_version: 'v1', id: individual_account.id)
      assert_response :success
    end

    it 'shows accounts the user is a member of' do
      get(:show, api_version: 'v1', id: member_account.id)
      assert_response :success
    end

    it 'does not show unapproved memberships' do
      get(:show, api_version: 'v1', id: unapproved_account.id)
      assert_response :not_found
    end

    it 'indexes only member accounts' do
      get(:index, api_version: 'v1')
      assert_response :success
      body = JSON.parse(response.body)
      ids = body['_embedded']['prx:items'].map { |item| item['id'] }
      body['count'].must_equal 2
      body['total'].must_equal 2
      ids.must_include individual_account.id
      ids.must_include member_account.id
      ids.wont_include unapproved_account.id
    end

    it 'creates an account' do
      post :create, { name: 'Foo Bar', login: 'foobar', path: 'foobar' }.to_json, api_version: 'v1'
      assert_response :success
      new_account = Account.find(JSON.parse(response.body)['id'])
      new_account.path.must_equal 'foobar'
    end

    # Simulates a post to /api/v1/authorization/users/:user_id/accounts
    it 'creates an account with user' do
      post :create, { name: user_without_account.name }.to_json, { api_version: 'v1', user_id: user_without_account.id }
      assert_response :success

      new_account_id = JSON.parse(response.body)['id']
      new_account = Account.find(new_account_id)
      new_membership = Membership.find_by!(user: user_without_account, account: new_account)
      new_account.path.must_equal user_without_account.login
    end
  end

  describe 'with no token' do

    it 'will not show you anything' do
      get(:show, api_version: 'v1', id: individual_account.id)
      assert_response :unauthorized
    end

    it 'will not index you anything' do
      get(:index, api_version: 'v1')
      assert_response :unauthorized
    end

  end

end
