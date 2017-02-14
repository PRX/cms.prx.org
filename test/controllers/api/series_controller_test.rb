require 'test_helper'

describe Api::SeriesController do
  let(:user) { create(:user) }
  let(:account) { user.individual_account }
  let(:series) { create(:series, account: account) }
  let(:v3_series) { create(:series_v3, account: account) }

  it 'should show' do
    get(:show, api_version: 'v1', format: 'json', id: series.id)
    assert_response :success
  end

  it 'should list' do
    series.wont_be_nil
    get(:index, api_version: 'v1', format: 'json')
    assert_response :success
    assert_not_nil assigns[:series]
    assigns[:series].must_include series
  end

  describe 'filtering' do
    it 'should filter v4 stories' do
      series.must_be :v4?
      v3_series.wont_be :v4?
      get(:index, api_version: 'v1', format: 'json', filters: 'v4')
      assert_response :success
      assert_not_nil assigns[:series]
      assigns[:series].must_include series
      assigns[:series].wont_include v3_series
    end

    it 'should list matching series for text' do
      series = create(:series, title: 'You are all Weirdos')
      series2 = create(:series, title: 'We are all Freakazoids')
      get(:index, api_version: 'v1', format: 'json', filters: 'text=weirdos')
      assert_response :success
      assert_not_nil assigns[:series]
      assigns[:series].must_include series
      assigns[:series].wont_include series2
    end
  end

  describe 'sorting' do
    let (:series_a) { create(:series, title: 'aaaa') }
    let (:series_b) { create(:series, title: 'bbbb') }

    before do
      series_a
      series_b
    end

    it 'should sort series by title asc' do
      get(:index, api_version: 'v1', format: 'json', sorts: 'title:asc')
      assert_response :success
      assert_not_nil assigns[:series]
      assigns[:series].first.must_equal series_a
    end
  end

  describe 'with a valid token' do
    around do |test|
      token = StubToken.new(account.id, ['member'], user.id)
      @request.env['CONTENT_TYPE'] = 'application/json'
      @controller.stub(:prx_auth_token, token) { test.call }
    end

    it 'creates a series' do
      post :create, { title: 'foobar' }.to_json, api_version: 'v1', account_id: account.id
      assert_response :success
      new_series = Series.find(JSON.parse(response.body)['id'])
      new_series.title.must_equal 'foobar'
      new_series.must_be :v4?
      new_series.account_id.must_equal account.id
    end

    it 'creates a series with set account uri' do
      series_params = {
        title: 'foobar',
        set_account_uri: "/api/v1/accounts/#{account.id}"
      }
      post :create, series_params.to_json, api_version: 'v1'
      assert_response :success
      new_series = Series.find(JSON.parse(response.body)['id'])
      new_series.title.must_equal 'foobar'
      new_series.must_be :v4?
      new_series.account_id.must_equal account.id
    end

    it 'creates a series with no account specified' do
      post :create, { title: 'foobar' }.to_json, api_version: 'v1'
      assert_response :success
      new_series = Series.find(JSON.parse(response.body)['id'])
      new_series.title.must_equal 'foobar'
      new_series.must_be :v4?
      new_series.account_id.must_equal account.id
    end

    it 'updates a series' do
      Series.find(series.id).title.wont_equal('foobar')
      put :update, { title: 'foobar' }.to_json, api_version: 'v1', id: series.id
      assert_response :success
      Series.find(series.id).title.must_equal('foobar')
    end

    it 'deletes a series' do
      delete :destroy, api_version: 'v1', id: series.id
      response.status.must_equal 204
      Series.where(id: series.id).must_be :empty?
    end
  end
end
