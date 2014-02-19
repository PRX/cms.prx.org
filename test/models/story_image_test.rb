require 'test_helper'

describe StoryImage do

  let(:story_image) { FactoryGirl.create(:story_image) }

  it 'has a table defined' do
    StoryImage.table_name.must_equal 'piece_images'
  end

  it 'returns an owner' do
    story_image.owner.must_be_instance_of Story
  end

  it 'has an url' do
    story_image.url.must_match "/public/piece_images/#{story_image.id}/test.png"
  end

end
