require 'test_helper'

describe StoryImage do

  let(:story_image) { FactoryGirl.create(:story_image) }

  it 'has a table defined' do
    StoryImage.table_name.must_equal 'piece_images'
  end

end
