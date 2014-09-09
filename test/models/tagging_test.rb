require 'test_helper'

describe Tagging do
  let(:tagging) { build_stubbed(:tagging) }

  it 'has a table defined' do
    Tagging.table_name.must_equal 'taggings'
  end

  it 'has a user tag' do
    tagging.must_respond_to(:user_tag)
  end

  it 'has a taggable' do
    tagging.must_respond_to(:taggable)
  end

  it 'validates uniqueness of tag to taggable' do
    taggable = create(:story)
    tagging1 = create(:tagging, taggable: taggable)
    tagging2 = build(:tagging, user_tag: tagging1.user_tag, taggable: taggable)

    tagging2.wont_be :valid?
  end
end
