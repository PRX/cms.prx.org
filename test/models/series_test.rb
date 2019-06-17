require 'test_helper'

describe Series do
  let(:episode_start_at) { Time.parse('2013-06-01T00:00:00-05:00') }
  let(:series) { create(:series, episode_start_at: episode_start_at) }
  let(:v3_series) { create(:series_v3, episode_start_at: episode_start_at) }

  describe 'basics' do
    it 'is deleted by default' do
      create(:series).must_be :deleted?
    end

    it 'has stories' do
      series.stories.count.must_be :>, 0
    end

    it 'has a story count' do
      public_stories_count = series.stories.published.network_visible.series_visible.count
      series.public_stories.count.must_equal public_stories_count
    end

    it 'changes account_id for stories when own account changes' do
      series.update_attributes!(account_id: 123)
      series.stories.all.each do |story|
        story.account_id.must_equal 123
      end
    end

    it 'changes account_id for audio files when own account changes' do
      series.update_attributes!(account_id: 123)
      series.audio_files.all.each do |af|
        af.account_id.must_equal 123
      end
    end
  end

  describe 'deleting' do
    it 'actually deletes v4 series' do
      series.destroy!
      Series.unscoped.where(id: series.id).count.must_equal 0
    end

    it 'soft deletes v3 series' do
      v3_series.destroy!
      Series.unscoped.where(id: v3_series.id).count.must_equal 1
    end
  end

  describe '#images' do
    let(:series) { create(:series, images_count: 0) }
    let(:image_none) { create(:series_image, series: series, purpose: '') }
    let(:image_prof) { create(:series_image, series: series, purpose: 'profile') }
    let(:image_thum) { create(:series_image, series: series, purpose: 'thumbnail') }

    it 'gets the profile image by default' do
      image_none.wont_be_nil
      image_prof.wont_be_nil
      image_thum.wont_be_nil
      series.default_image.must_equal image_prof
      series.images.first.wont_equal image_prof
    end

    it 'gets any image if no profile image' do
      image_none.wont_be_nil
      series.default_image.must_equal image_none
      series.images.first.must_equal image_none
    end
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

  describe '.create_from_feed' do
    let(:user) { create(:user) }
    let(:account) { create(:account, id: 8, opener: user) }
    let(:series) { create(:series, account: account) }
    let(:podcast_url) { 'http://feeds.prx.org/transistor_stem' }
    let(:importer) { PodcastImport.create!(user: user, account: account, url: podcast_url) }

    it 'creates a series import and schedules an import for later' do
      stub_request(:get, 'http://feeds.prx.org/transistor_stem').
        to_return(status: 200, body: test_file('/fixtures/transistor_two.xml'), headers: {})
      assert_send([importer, :import_series!])
      assert_send([importer, :import_later, [{ import_series: false }]])

      PodcastImport.stub(:create!, importer) do
        # note that we are mocking ^ so these args are unused
        Series.create_from_feed('http://feeds.prx.org/transistor_stem', user, account)
      end
    end
  end

end
