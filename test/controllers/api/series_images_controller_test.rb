require 'test_helper'

describe Api::SeriesImagesController do

  let(:series_image) { FactoryGirl.create(:series_image) }

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
