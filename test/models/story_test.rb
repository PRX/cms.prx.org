require 'test_helper'

describe Story do

  let(:story) { build_stubbed(:story, audio_versions_count: 10) }
  let(:promos_only) { build_stubbed(:story_promos_only) }

  describe 'basics' do

    it 'has a table defined' do
      Story.table_name.must_equal 'pieces'
    end

    it 'has points' do
      story.points.must_equal 10
    end

    it 'has purchases' do
      story.must_respond_to :purchases
    end

    it 'is v4 by default' do
      create(:story).must_be :v4?
    end

    it 'is deleted by default' do
      create(:story).must_be :deleted?
    end
  end

  describe 'using default audio version' do

    it 'finds default audio' do
      story.audio_versions.count.must_equal 10
      story.default_audio_version.audio_files.count.must_be :>=, 1
      story.default_audio.wont_be_nil
    end

    it 'has a content advisory from the default audio version' do
      story.content_advisory.must_equal story.default_audio_version.content_advisory
    end

    it 'produces a nil content advisory for no default audio version' do
      story.stub(:default_audio_version, nil) do
        story.content_advisory.must_be_nil
      end
    end

    it 'has timing and cues from the default audio version' do
      story.timing_and_cues.must_equal story.default_audio_version.timing_and_cues
    end

    it 'produces a nil timing and cues for no default audio version' do
      story.stub(:default_audio_version, nil) do
        story.timing_and_cues.must_be_nil
      end
    end

    it 'has empty default audio with no default_audio_version' do
      story.stub(:default_audio_version, nil) do
        story.default_audio.must_equal []
      end
    end

    it 'returns 0 for duration when there is no default audio version' do
      story.stub(:default_audio_version, nil) do
        story.duration.must_equal 0
      end
    end

    it 'has a transcript from the default audio version' do
      story.transcript.must_equal story.default_audio_version.transcript
    end
  end

  describe '#default_image' do

    it 'returns the first image when one is present' do
      story.stub(:images, [:image, :second_image]) do
        story.default_image.must_equal :image
      end
    end

    it 'returns nil when no image is present' do
      story.stub(:images, []) do
        story.default_image.must_equal nil
      end
    end

    it 'falls back to series image when present' do
      series = build_stubbed(:series, image: build_stubbed(:series_image))
      story.images = []
      story.stub(:series, series) do
        story.default_image.must_equal series.image
      end
    end

  end

  describe '#tags' do
    it 'has topics' do
      story.must_respond_to(:topics)
    end

    it 'has tones' do
      story.must_respond_to(:tones)
    end

    it 'has formats' do
      story.must_respond_to(:formats)
    end

    it 'can have user tags' do
      story.must_respond_to(:user_tags)
    end

    it 'returns tones, topics, formats, and user tags with #tags' do
      topic = create(:topic, story: story, name: 'Asian')
      tones = create(:tone, story: story, name: 'Amusing')
      format = build(:format, story: story, name: 'Fundraising for Air')
      format.save(validate: false)
      user_tag = create(:user_tag, name: 'user_tag')
      tagging = create(:tagging, taggable: story, user_tag: user_tag)

      story.tags.must_include 'Asian'
      story.tags.must_include 'Amusing'
      story.tags.must_include 'Fundraising'
      story.tags.must_include 'user_tag'
    end
  end

  describe '#subscription_episode?' do
    let(:series) { build_stubbed(:series) }

    before :each do
      story.series = series
    end

    it 'returns true if series is subscribable' do
      story.must_be :subscription_episode?
    end

    it 'returns false otherwise' do
      series.subscription_approval_status = Series::SUBSCRIPTION_NEW

      story.wont_be :subscription_episode?
    end

    describe '#episode_date' do
      it 'returns the episode date' do
        story.episode_number = 3
        create(:schedule, series: series)

        story.episode_date.must_equal series.get_datetime_for_episode_number(3)
      end
    end
  end

  describe 'publishing' do

    let(:story) { create(:story) }

    it 'publishes a story' do
      story.published_at = nil
      story.publish!
      story.published_at.wont_be_nil
    end

    it 'wont publish when already published' do
      lambda do
        story.publish!
        story.publish!
      end.must_raise(RuntimeError)
    end

    it 'unpublishes a story' do
      story.published_at = Time.now
      story.unpublish!
      story.published_at.must_be_nil
    end

    it 'wont unpublish an unpublished story' do
      lambda do
        story.unpublish!
        story.unpublish!
      end.must_raise(RuntimeError)
    end
  end

  describe 'deleting' do
    let(:story) { create(:story) }
    let(:story_v3) { create(:story_v3) }

    it 'actually deletes v4 stories' do
      story.destroy!
      Story.unscoped.where(id: story.id).count.must_equal 0
    end

    it 'soft deletes v3 stories' do
      story_v3.destroy!
      Story.unscoped.where(id: story_v3.id).count.must_equal 1
    end
  end

  describe 'scopes' do
    it 'wont include network_only stories' do
      story = create(:story, network_only_at: Time.now)
      Story.where(id: story.id).must_include story
      Story.where(id: story.id).network_visible.wont_include story
    end

    it 'wont include subscriber_only stories' do
      series = create(:series, subscription_approval_status: Series::SUBSCRIPTION_PRX_APPROVED, subscriber_only_at: Time.now)
      story = create(:story, series_id: series.id)
      Story.where(id: story.id).must_include story
      Story.where(id: story.id).series_visible.wont_include story
    end

    it 'wont include non-v4 stories' do
      story = create(:story)
      story.app_version.must_equal 'v4'
      Story.where(id: story.id).v4.must_include story
      story.update_attributes(app_version: 'v3', deleted_at: nil)
      Story.where(id: story.id).v4.wont_include story
      story.update_attributes(app_version: 'foobar', deleted_at: nil)
      Story.where(id: story.id).v4.wont_include story
    end

    it 'searches text for title and description' do
      story = create(:story,
                     title: 'Some Weirdo',
                     description: 'Unique thing',
                     short_description: 'Lacking sense')

      Story.match_text('weirdo').must_include story
      Story.match_text('unique').must_include story
      Story.match_text('lack').must_include story
      Story.match_text('random').wont_include story
    end

    it 'returns public only stories' do
      story = create(:story)
      story_n = create(:story, network_only_at: Time.now)
      series = create(:series, subscription_approval_status: Series::SUBSCRIPTION_PRX_APPROVED, subscriber_only_at: Time.now)
      story_s = create(:story, series_id: series.id)
      story_u = create(:story, published_at: nil)

      Story.public_stories.must_include story
      Story.public_stories.wont_include story_n
      Story.public_stories.wont_include story_s
      Story.public_stories.wont_include story_u
    end
  end

  describe 'default scope' do
    it 'includes non-deleted v3 stories' do
      story = create(:story_v3)
      Story.where(id: story.id).must_include story
    end

    it 'does not include deleted v3 stories' do
      story = create(:story_v3)
      story.destroy!
      story.deleted_at.wont_be_nil
      Story.where(id: story).wont_include story
    end

    it 'includes non-deleted v4 stories' do
      story = create(:story, deleted_at: nil, app_version: 'v4')
      Story.where(id: story.id).must_include story
    end

    it 'includes "deleted" v4 stories' do
      story = create(:story, deleted_at: Time.now, app_version: 'v4')
      Story.where(id: story.id).must_include story
    end
  end
end
