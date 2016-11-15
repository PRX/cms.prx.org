require 'test_helper'

describe Api::DistributionsController do

  let(:distribution) { create(:distribution) }

  it 'should show' do
    get :show, api_request_opts(series_id: distribution.owner.id, id: distribution.id)
    assert_response :success
  end
end
