require 'test_helper'

describe Api::AccountImagesController do
  let(:account_image) { create(:account_image) }

  it 'should show' do
    get(:show, api_request_opts(account_id: account_image.account_id))
    assert_response :success
  end
end
