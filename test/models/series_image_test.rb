require 'test_helper'

describe SeriesImage do

  let(:series_image) { FactoryGirl.create(:series_image) }

  it 'has a table defined' do
    SeriesImage.table_name.must_equal 'series_images'
  end

  it 'has an url' do
    series_image.url.must_match "/public/series_images/#{series_image.id}/test.png"
  end

end
