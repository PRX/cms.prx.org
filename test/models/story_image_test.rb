require 'test_helper'

describe StoryImage do

  let(:story_image) { FactoryGirl.create(:story_image) }

  let(:story_image_uploaded) { FactoryGirl.create(:story_image_uploaded) }

  it 'has a table defined' do
    StoryImage.table_name.must_equal 'piece_images'
  end

  it 'has an asset_url' do
    story_image.asset_url.must_match "/public/piece_images/#{story_image.id}/test.png"
  end

  it 'has an public_asset_filename' do
    story_image.public_asset_filename.must_equal story_image.filename
  end

  it 'can have a url from the upload' do
    story_image_uploaded.public_asset_filename.must_equal 'test.jpg'
  end

  it 'considers nil statuses to be complete uploads' do
    story_image.fixerable_final?.must_equal true
    story_image.public_asset_filename.must_equal story_image.filename
    story_image.update!(status: nil)
    story_image.fixerable_final?.must_equal true
    story_image.public_asset_filename.must_equal story_image.filename
    story_image.update!(status: 'invalid', upload_path: 'http://foo.bar/fromupload.jpg')
    story_image.fixerable_final?.must_equal false
    story_image.public_asset_filename.must_equal 'fromupload.jpg'
  end

  it 'returns the upload filename until status is complete' do
    story_image_uploaded.update!(caption: 'print')
    story_image.filename.must_equal 'test.png'
    story_image_uploaded.filename.must_equal 'test.jpg'
    story_image_uploaded.update!(filename: 'real.jpg')
    story_image_uploaded.filename.must_equal 'test.jpg'
    story_image_uploaded.update!(status: 'complete')
    story_image_uploaded.filename.must_equal 'real.jpg'
  end

end
