require 'test_helper'

describe Api::UserImagesController do
  let(:user) { user_image.user }
  let(:account) { user.default_account }
  let(:user_image) { create(:user_image) }

  it 'should show' do
    get(:show, api_request_opts(user_id: user_image.user_id))
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

    it 'triggers image copy on update' do
      image_hash = { credit: 'credit' }
      mock_image = Minitest::Mock.new user_image

      mock_image.expect :process!, true

      @controller.stub :authorize, true do
        @controller.stub :update_resource, mock_image do
          put(:update, image_hash.to_json, api_request_opts(user_id: user.id))
        end
      end

      mock_image.verify
    end

    it 'triggers image copy on create' do
      image_hash = {
        upload: 'http://thisisatest.com/guid1/image.gif',
        set_user_uri: api_user_url(user)
      }

      user_image = UserImage.where(user: user).build
      mock_image = Minitest::Mock.new(user_image)

      mock_image.expect :process!, true

      @controller.stub :authorize, true do
        @controller.stub :create_resource, mock_image do
          post(:create, image_hash.to_json, api_request_opts(user_id: user.id))
        end
      end

      mock_image.verify
    end

  end
end
