require 'test_helper'

describe Api::Auth::SeriesController do
  let(:user) { create(:user) }
  let(:token) { StubToken.new(account.id, ['member'], user.id) }
  let(:account) { user.individual_account }
  let(:series) { create(:series, account: account) }
  let(:v3_series) { create(:series_v3, account: account) }
  let(:other_account_series) { create(:series) }

  before { Series.delete_all }

  describe 'with a valid token' do

    around do |test|
      @controller.stub(:prx_auth_token, token) { test.call }
    end

    it 'indexes series under their account' do
      series && v3_series && other_account_series
      get(:index, api_version: 'v1', account_id: account.id)
      assert_response :success
      assert_not_nil assigns[:series]
      assigns[:series].must_include series
      assigns[:series].must_include v3_series
      assigns[:series].wont_include other_account_series
    end

    it 'filters v4 series' do
      series && v3_series
      get(:index, api_version: 'v1', account_id: account.id, filters: 'v4')
      assert_response :success
      assert_not_nil assigns[:series]
      assigns[:series].must_include series
      assigns[:series].wont_include v3_series
    end

    it 'does not show unowned series' do
      get(:show, api_version: 'v1', id: other_account_series.id)
      assert_response :not_found
    end

  end

  describe 'with no token' do

    it 'will not show you anything' do
      get(:show, api_version: 'v1', id: series.id)
      assert_response :unauthorized
    end

    it 'will not index you anything' do
      get(:index, api_version: 'v1', account_id: account.id)
      assert_response :unauthorized
    end

  end

end
