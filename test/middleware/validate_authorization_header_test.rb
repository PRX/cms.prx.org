require 'test_helper'

describe ValidateAuthorizationHeader do
  let(:valauth) { ValidateAuthorizationHeader.new(TestObject.new) }
  let(:access_token) { 'eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiJ9.eyJzdWIiOm51bGwsImV4cCI6MzYwMCwiaWF0IjoxNDExNjY4NDIyLCJ0b2tlbl90eXBlIjoiYmVhcmVyIiwic2NvcGUiOm51bGx9.MEUCICZEJN1c-oCAteB7nH6QA7hvD6a66jTRi4E2dTb0vNHOAiEA5f9HK04GnsDnaNpA_SdwyW-nrCerb96M4PHLxmHrQ9U' }

  describe '#call' do
    it 'does nothing if there is no authorization header' do
      env = {}

      valauth.call(env).must_equal {}
    end

    it 'returns 401 if verification fails' do
      env = {'Authorization' => 'Bearer ' + access_token }

      valauth.public_key.stub(:key, nil) do
        valauth.call(env).must_equal [401, {'Content-Type' => 'application/json'}, [{status: 401, error: 'Invalid JSON Web Token'}.to_json]]
      end
    end

    it 'attaches claims to request params if verification passes' do
      env = {'Authorization' => 'Bearer ' + access_token }
      claims = {'sub'=>nil, 'exp'=>3600, 'iat'=>1411668422, 'token_type'=>'bearer', 'scope'=>nil}

      valauth.call(env).must_equal env.merge(claims)
    end
  end
end
