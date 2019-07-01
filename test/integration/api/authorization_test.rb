require 'test_helper'

class Api::AuthorizationTest < ActionDispatch::IntegrationTest
  before do
    FactoryGirl.create(:user, id: 8)
    stub_request(:get, 'http://id.prx.docker/api/v1/certs').
      to_return(:status => 200, :body => test_file('/fixtures/id_certs.json'), :headers => {})
  end

  test 'parses handles parsing a incomplete header' do
    get api_authorization_path, {}, { AUTHORIZATION: 'Bearer '}
    assert_response :unauthorized
  end

  test 'parses a valid header and authorizes the request' do
    Timecop.freeze('2019-07-01T17:35:29+00:00') do
      get api_authorization_path,
          {},
          { AUTHORIZATION: "Bearer #{test_file('/fixtures/valid_token_july_2019.txt')}" }
      assert_response :ok
    end
  end

  test 'parses an invalid header and denies the request' do
    # adds 10 minutes to the above ^ timestamp
    Timecop.freeze('2019-07-01T17:45:29+00:00') do
      get api_authorization_path,
          {},
          { AUTHORIZATION: "Bearer #{test_file('/fixtures/valid_token_july_2019.txt')}" }
      assert_response :ok
    end
  end
end
