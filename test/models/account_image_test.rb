require 'test_helper'

describe AccountImage do

  let(:account_image) { FactoryGirl.create(:account_image) }

  it 'has a table defined' do
    AccountImage.table_name.must_equal 'account_images'
  end

  it 'returns an owner' do
    account_image.owner.must_be_instance_of Account
  end

  it 'has an url' do
    account_image.url.must_match "/public/account_images/#{account_image.id}/test.png"
  end

end
