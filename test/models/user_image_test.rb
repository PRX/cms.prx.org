require 'test_helper'

describe UserImage do

  let(:user_image) { FactoryGirl.create(:user_image) }

  it 'has a table defined' do
    UserImage.table_name.must_equal 'user_images'
  end

  it 'has an url' do
    user_image.url.must_match "/public/user_images/#{user_image.id}/test.png"
  end

end
