require 'test_helper'

describe AccountImage do

  let(:account_image) { FactoryGirl.create(:account_image) }

  it 'has a table defined' do
    AccountImage.table_name.must_equal 'account_images'
  end

  it 'has an asset_url' do
    account_image.asset_url.must_match "/public/account_images/#{account_image.id}/test.png"
  end

  it 'has an public_asset_filename' do
    account_image.public_asset_filename.must_equal account_image.filename
  end

end
