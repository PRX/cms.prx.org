require 'test_helper'

describe SeriesImage do

  let(:series_image) { FactoryGirl.create(:series_image) }

  it 'has a table defined' do
    SeriesImage.table_name.must_equal 'series_images'
  end

  it 'has an asset_url' do
    series_image.asset_url.must_match "/public/series_images/#{series_image.id}/test.png"
  end

  it 'has an public_asset_filename' do
    series_image.public_asset_filename.must_equal series_image.filename
  end

end
