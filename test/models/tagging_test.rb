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

  it 'has an owner' do
    tagging.owner.wont_be_nil
  end

  it 'uses an owned policy' do
    Tagging.policy_class.must_equal OwnedPolicy
  end

  it 'validates uniqueness of tag to taggable' do
    taggable = create(:story)
    tagging1 = create(:tagging, taggable: taggable)
    tagging2 = build(:tagging, user_tag: tagging1.user_tag, taggable: taggable)

    tagging2.wont_be :valid?
  end

  it 'allows a story and a playlist to have the same tag' do
    story = create(:story)
    playlist = create(:playlist, id: story.id)
    tag = create(:user_tag)
    tagging1 = create(:tagging, user_tag: tag, taggable: story)
    tagging2 = build(:tagging, user_tag: tag, taggable: playlist)

    tagging2.must_be :valid?
  end

  it 'updates the taggable\'s timestamp' do
    taggable = create(:story)
    taggable.update_attribute(:updated_at, 3.minutes.ago)
    stamp = taggable.updated_at
    create(:tagging, taggable: taggable)
    taggable.reload
    stamp.must_be :<, taggable.updated_at
  end
end
