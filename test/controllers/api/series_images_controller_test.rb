require 'test_helper'

describe Api::SeriesImagesController do
  let(:user) { create(:user) }
  let(:series) { create(:series, account: user.individual_account) }
  let(:series_image) { create(:series_image, series: series) }

  it 'should show' do
    series_image
    get(:show, api_request_opts(series_id: series_image.series_id))
    assert_response :success
  end
end
