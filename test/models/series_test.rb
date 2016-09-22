require 'test_helper'

describe Series do
  let(:episode_start_at) { Time.parse('2013-06-01T00:00:00-05:00') }
  let(:series) { create(:series, episode_start_at: episode_start_at) }
  let(:v3_series) { create(:series_v3, episode_start_at: episode_start_at) }

  it 'has stories' do
    series.stories.count.must_be :>, 0
  end

  it 'has a story count' do
    series.story_count.must_equal series.stories.published.network_visible.series_visible.count
  end

  it 'actually deletes v4 series' do
    series.destroy!
    Series.where(id: series.id).with_deleted.count.must_equal 0
  end

  it 'soft deletes v3 series' do
    v3_series.destroy!
    Series.where(id: v3_series.id).with_deleted.count.must_equal 1
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

    it 'returns if the series is subscriber only' do
      series.subscription_approval_status = Series::SUBSCRIPTION_STARTED
      series.subscriber_only_at = Time.now
      series.wont_be :subscriber_only?

      series.subscription_approval_status = Series::SUBSCRIPTION_PRX_APPROVED
      series.must_be :subscriber_only?
    end

  end

  describe 'scopes' do
    it 'wont include non-v4 series' do
      series.app_version.must_equal 'v4'
      v3_series.app_version.must_equal 'v3'
      Series.where(id: [series.id, v3_series.id]).v4.must_include series
      Series.where(id: [series.id, v3_series.id]).v4.wont_include v3_series
    end

    it 'searches text for title and description' do
      series = create(:series,
                      title: 'Some Weirdo',
                      description: 'Unique thing',
                      short_description: 'Lacking sense')

      Series.match_text('weirdo').must_include series
      Series.match_text('unique').must_include series
      Series.match_text('lack').must_include series
      Series.match_text('random').wont_include series
    end
  end

end
