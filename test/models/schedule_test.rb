require 'test_helper'

describe Schedule do
  let(:schedule) { build_stubbed(:schedule) }

  it 'should have a table defined' do
    Schedule.table_name.must_equal 'schedules'
  end

  it 'should have a series' do
    schedule.must_respond_to(:series)
  end

  it 'uses series policy' do
    Schedule.policy_class.must_equal SeriesAttributePolicy
  end
end
