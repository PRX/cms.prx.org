require 'test_helper'

describe UserTag do
  let(:user_tag) { build_stubbed(:user_tag) }

  it 'has a table defined' do
    UserTag.table_name.must_equal 'tags'
  end

  it 'has taggings' do
    user_tag.must_respond_to(:taggings)
  end

  it 'has taggables' do
    user_tag.must_respond_to(:taggables)
  end
end
