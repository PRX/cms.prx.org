require 'test_helper'

describe PublicCalendarTitlePlaceholderBuilder do

  describe '#new' do
    it 'only requires a published_released_at datetime' do
      p = PublicCalendarTitlePlaceholderBuilder.new(Time.now)
      p.present?.must_equal(true)
    end
  end

  describe '#generate!' do
    let(:t) { Time.now }
    let(:season_id) { 10 }
    let(:episode_id) { 30 }

    it 'generates a title using the published_released_at' do
      p = PublicCalendarTitlePlaceholderBuilder.new(t)
      p.generate!.must_equal("Publish Releas At: #{t.to_s}")
    end

    it 'generates a title using season_identifier' do
      p = PublicCalendarTitlePlaceholderBuilder.new(t, season_id)
      p.generate!.must_equal("Season: #{season_id}")
    end

    it 'generates a title using the episode id' do
      p = PublicCalendarTitlePlaceholderBuilder.new(t, nil, episode_id)
      p.generate!.must_equal("Episode: #{episode_id}")
    end

    it 'generates a title using the episode and season id' do
      p = PublicCalendarTitlePlaceholderBuilder.new(t, season_id, episode_id)
      p.generate!.must_equal("Season: #{season_id}, Episode: #{episode_id}")
    end
  end
end
