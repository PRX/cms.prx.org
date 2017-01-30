require 'test_helper'

describe Api::Auth::AccountsController do

  let (:user) { create(:user_with_accounts, group_accounts: 2) }

  let (:individual_account) { user.individual_account }
  let (:random_account) { create(:account) }
  let (:member_account) { create(:account) }
  let (:unapproved_account) { create(:account)}

  let (:token) { OpenStruct.new.tap { |t|
    t.authorized_resources = {
      member_account.id => "member",
      individual_account.id => "admin"
    }
    t.user_id = user.id
    }
  }

  describe 'with a valid token' do

    around do |test|
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

    it 'does not show non-member accounts' do
      get(:show, api_version: 'v1', id: random_account.id)
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
      ids.wont_include random_account.id
    end

    it 'gets list of approved accounts for a user from users token' do
      get(:index, api_version: 'v1')
      assert_response :success
      user.reload.approved_accounts.wont_be_nil
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
