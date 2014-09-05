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

    topic.valid?.must_equal false
  end

  it 'has an NPR topic id when appropriate' do
    topic.name = 'Art'

    topic.npr_topic_id.must_equal 1047
  end

  it 'does not have an NPR topic id when appropriate' do
    topic.name = 'African-American'

    topic.npr_topic_id.must_be_nil
  end
end
