require 'test_helper'

describe Api::SeriesImagesController do
  let(:user) { create(:user) }
  let(:series) { create(:series, account: user.individual_account) }
  let(:series_image) { create(:series_image, series: series) }

  it 'should show' do
    get(:show, { api_version: 'v1', format: 'json', id: series_image.id } )
    assert_response :success
  end

  it 'should list' do
    series_image.id.wont_be_nil
    get(:index, { api_version: 'v1', format: 'json' } )
    assert_response :success
  end
end
