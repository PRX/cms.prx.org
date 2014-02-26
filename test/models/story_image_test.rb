require 'test_helper'

describe StoryImage do

  let(:story_image) { FactoryGirl.create(:story_image) }

  it 'has a table defined' do
    StoryImage.table_name.must_equal 'piece_images'
  end

  it 'has an asset_url' do
    story_image.asset_url.must_match "/public/piece_images/#{story_image.id}/test.png"
  end

  it 'has an public_asset_filename' do
    story_image.public_asset_filename.must_equal story_image.filename
  end

end
