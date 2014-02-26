require 'test_helper'

describe UserImage do

  let(:user_image) { FactoryGirl.create(:user_image) }

  it 'has a table defined' do
    UserImage.table_name.must_equal 'user_images'
  end

  it 'has an asset_url' do
    user_image.asset_url.must_match "/public/user_images/#{user_image.id}/test.png"
  end

  it 'has an public_asset_filename' do
    user_image.public_asset_filename.must_equal user_image.filename
  end

end
