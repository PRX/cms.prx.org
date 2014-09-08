require 'test_helper'

describe Topic do

  let(:topic) { build_stubbed(:topic) }

  it 'has a table defined' do
    Topic.table_name.must_equal 'topics'
  end

  it 'has a story' do
    topic.must_respond_to 'story'
  end

  it 'validates that name is in topics array' do
    topic.name = 'something else'

    topic.wont_be :valid?
  end

  it 'validates uniqueness of topic to story' do
    story = create(:story)
    topic1 = create(:topic, story: story)
    topic2 = build(:topic, name: topic1.name, story: story)

    topic2.wont_be :valid?
  end

  describe '#to_tag' do
    it 'returns the topic name' do
      topic.to_tag.must_equal topic.name
    end
  end
end
