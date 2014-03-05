require 'test_helper'

describe Series do

  let(:series) { FactoryGirl.create(:series) }

  it 'has stories' do
    series.stories.count.must_be :>, 0
  end

  it 'has a story count' do
    series.story_count.must_equal series.stories.published.count
  end

end
