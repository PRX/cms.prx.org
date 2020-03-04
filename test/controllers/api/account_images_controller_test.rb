require 'test_helper'

describe Api::AccountImagesController do
  let(:user) { create(:user) }
  let(:account_image) { create(:account_image) }
  let(:account) { account_image.account }

  it 'should show' do
    get(:show, api_request_opts(account_id: account_image.account_id))
    assert_response :success
  end

  describe 'write' do

    let(:token) { StubToken.new(account.id, ['member'], user.id) }

    before(:each) do
      class << @controller; attr_accessor :prx_auth_token; end
      @controller.prx_auth_token = token
      @request.env['CONTENT_TYPE'] = 'application/json'
      clear_messages
    end

    it 'triggers image transform! on update' do
      image_hash = { credit: 'credit' }
      mock_image = Minitest::Mock.new account_image

      mock_image.expect :transform!, true

      @controller.stub :authorize, true do
        @controller.stub :update_resource, mock_image do
          put(:update, image_hash.to_json, api_request_opts(account_id: account.id))
        end
      end

      mock_image.verify
    end

    it 'triggers image transform! on create' do
      image_hash = {
        upload: 'http://thisisatest.com/guid1/image.gif',
        set_series_uri: api_account_url(account)
      }

      account_image = AccountImage.where(account_id: account.id).build
      mock_image = Minitest::Mock.new(account_image)

      mock_image.expect :transform!, true

      @controller.stub :authorize, true do
        @controller.stub :create_resource, mock_image do
          post(:create, image_hash.to_json, api_request_opts(account_id: account.id))
        end
      end

      mock_image.verify
    end

  end

end
