require 'test_helper'

describe Api::AccountsController do
  let(:account) { create(:account) }
  let(:membership) { create(:membership, account: account) }
  let (:user_without_account) { create(:user, with_individual_account: false) }
  let (:user) { create(:user) }
  let (:write_token) { StubToken.new(nil, nil, user_without_account.id) }
  let (:token) { StubToken.new(nil, ['account'], user.id) }

  it 'should show' do
    get(:show, { api_version: 'v1', format: 'json', id: account.id })
    assert_response :success
  end

  it 'should list' do
    account.id.wont_be_nil
    get(:index, { api_version: 'v1', format: 'json' })
    assert_response :success
  end

  it 'should list users accounts' do
    membership.user.wont_be_nil
    membership.account.wont_be_nil

    get(:index, { api_version: 'v1', format: 'json', user_id: membership.user.id })
    assert_response :success
  end

  describe 'with a different user\'s token' do
    around do |test|
      @request.env['CONTENT_TYPE'] = 'application/json'
      @controller.stub(:prx_auth_token, token) { test.call }
    end

    it 'fails to create an account for user' do
      post :create, { kind: 'individual' }.to_json, { api_version: 'v1' }
      assert_response :unauthorized
    end
  end

  describe 'with the individual account user\'s token' do
    around do |test|
      @request.env['CONTENT_TYPE'] = 'application/json'
      @controller.stub(:prx_auth_token, write_token) { test.call }
    end

    it 'creates an individual account' do
      post :create, { kind: 'individual' }.to_json, { api_version: 'v1'}
      assert_response :success, JSON.parse(@response.body)['message']

      new_account = IndividualAccount.find(JSON.parse(response.body)['id'])
      Membership.find_by!(user: user_without_account, account: new_account)
      new_account.path.must_equal user_without_account.login
    end

    # Simulates a post to /api/v1/users/:user_id/accounts
    it 'creates an account with user' do
      post :create, { kind: 'individual' }.to_json,
           { api_version: 'v1', user_id: user_without_account.id }
      assert_response :success, JSON.parse(@response.body)['message']

      new_account = IndividualAccount.find(JSON.parse(response.body)['id'])
      Membership.find_by!(user: user_without_account, account: new_account)
      new_account.path.must_equal user_without_account.login
    end
  end
end
