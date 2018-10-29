require 'test_helper'

describe Api::AccountsController do
  let(:account) { create(:account) }
  let(:membership) { create(:membership, account: account) }
  let (:user_without_account) { create(:user, with_individual_account: false) }
  let (:user) { create(:user) }
  let (:write_token) { StubToken.new(nil, ['account:write'], nil) }
  let (:token) { StubToken.new(nil, ['account'], nil) }

  it 'should show' do
    get(:show, { api_version: 'v1', format: 'json', id: account.id } )
    assert_response :success
  end

  it 'should list' do
    account.id.wont_be_nil
    get(:index, { api_version: 'v1', format: 'json' } )
    assert_response :success
  end

  it 'should list users accounts' do
    membership.user.wont_be_nil
    membership.account.wont_be_nil

    get(:index, { api_version: 'v1', format: 'json', user_id: membership.user.id } )
    assert_response :success
  end

  describe 'with improperly scoped token' do
    around do |test|
      @request.env['CONTENT_TYPE'] = 'application/json'
      @controller.stub(:prx_auth_token, token) { test.call }
    end

    it 'fails to create an account' do
      post :create, { name: 'Foo Bar', login: 'foobar', path: 'foobar' }.to_json, api_version: 'v1'
      assert_response :unauthorized
    end

    it 'fails to create an account for a user' do
      post :create, { name: user_without_account.name }.to_json,
           { api_version: 'v1', user_id: user_without_account.id }
      assert_response :unauthorized
    end
  end

  describe 'with account:write scoped token' do
    around do |test|
      @request.env['CONTENT_TYPE'] = 'application/json'
      @controller.stub(:prx_auth_token, write_token) { test.call }
    end

    it 'creates an account' do
      post :create, { name: 'Foo Bar', login: 'foobar', path: 'foobar' }.to_json, api_version: 'v1'
      assert_response :success
      new_account = Account.find(JSON.parse(response.body)['id'])
      new_account.path.must_equal 'foobar'
    end

    # Simulates a post to /api/v1/authorization/users/:user_id/accounts
    it 'creates an account with user' do
      post :create, { name: user_without_account.name }.to_json,
           { api_version: 'v1', user_id: user_without_account.id }
      assert_response :success

      new_account_id = JSON.parse(response.body)['id']
      new_account = Account.find(new_account_id)
      Membership.find_by!(user: user_without_account, account: new_account)
      new_account.path.must_equal user_without_account.login
    end

    it 'throws error if creating account with user login matching existing path' do
      user_with_dupe_path = create(:user, with_individual_account: false)
      user_with_dupe_path.login = user.individual_account[:path]
      user_with_dupe_path.save!
      post :create, { name: user_with_dupe_path.name }.to_json,
           { api_version: 'v1', user_id: user_with_dupe_path.id }
      assert_response 409
    end
  end
end
