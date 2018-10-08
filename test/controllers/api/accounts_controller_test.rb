require 'test_helper'

describe Api::AccountsController do
  let(:account) { create(:account) }
  let(:membership) { create(:membership, account: account) }
  let(:user) { create(:user) }

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

  describe 'with a valid token' do
    around do |test|
      token = StubToken.new(account.id, ['member'], user.id)
      @request.env['CONTENT_TYPE'] = 'application/json'
      @controller.stub(:prx_auth_token, token) { test.call }
    end

    it 'creates an account' do
      post :create, { name: 'Foo Bar', login: 'foobar', path: 'foobar' }.to_json, api_version: 'v1'
      assert_response :success
      new_account = Account.find(JSON.parse(response.body)['id'])
      new_account.path.must_equal 'foobar'
    end
  end
end
