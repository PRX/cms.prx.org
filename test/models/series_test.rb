require 'test_helper'

describe Series do
  let(:episode_start_at) { Time.parse('2013-06-01T00:00:00-05:00') }
  let(:series) { create(:series, episode_start_at: episode_start_at) }

  it 'has stories' do
    series.stories.count.must_be :>, 0
  end

  it 'has a story count' do
    series.story_count.must_equal series.stories.published.count
  end

  describe '#subscribable?' do
    it 'returns true if status is approved' do
      series.subscription_approval_status = Series::SUBSCRIPTION_PRX_APPROVED
      series.save

      series.must_be :subscribable?
    end

    it 'returns false otherwise' do
      series.subscription_approval_status = Series::SUBSCRIPTION_STARTED
      series.save

      series.wont_be :subscribable?
    end
  end

  describe 'subauto methods' do
    before :each do
      (0..6).each { |d| (0..23).each { |h| create(:schedule, day: d, hour: h, series: series) } }
    end

    it 'can get the datetime from first episode number' do
      dt = series.get_datetime_for_episode_number(1)
      dt.must_equal episode_start_at
    end

    it 'can get the datetime from any episode number' do
      dt = series.get_datetime_for_episode_number(100)
      dt.must_equal episode_start_at + 99.hours
    end

    it 'returns the schedule info for an episode number' do
      sa = series.episode_start_at
      schedule = series.schedule_for_episode_number(1)

      schedule.must_equal((sa.wday * 24) + sa.hour)
    end
  end
end
