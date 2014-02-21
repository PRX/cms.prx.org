require 'test_helper'

describe Series do

  let(:series) { FactoryGirl.create(:series) }

  it 'has a table defined' do
    Series.table_name.must_equal 'series'
  end

  it 'has stories' do
    series.stories.count.must_be :>, 0
  end

end
