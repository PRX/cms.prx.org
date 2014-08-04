require 'test_helper'

describe Story do

  let(:story) { build_stubbed(:story_with_audio, audio_versions_count: 10) }
  let(:story_promos_only) { build_stubbed(:story_promos_only) }

  it 'has a table defined' do
    Story.table_name.must_equal 'pieces'
  end

  it 'finds default audio' do
    story.audio_versions.count.must_equal 10
    story.default_audio_version.audio_files.count.must_be :>=, 1
    story.default_audio.wont_be_nil
  end

  it 'can have promos only' do
    story_promos_only.promos_only_at.wont_be_nil
    story_promos_only.default_audio_version.must_equal story_promos_only.promos
  end

  it "has points" do
    story.points.must_equal 10
  end

  it 'has a content advisory from the default audio version' do
    story.content_advisory.must_equal story.default_audio_version.content_advisory
  end

  it 'produces a nil content advisory when there is no default audio version' do
    story.stub(:default_audio_version, nil) do
      story.content_advisory.must_be_nil
    end
  end


  it 'has timing and cues from the default audio version' do
    story.timing_and_cues.must_equal story.default_audio_version.timing_and_cues
  end

  it 'produces a nil timing and cues when there is no default audio version' do
    story.stub(:default_audio_version, nil) do
      story.timing_and_cues.must_be_nil
    end
  end

  it 'has breaks from the default audio version' do
    story.default_audio_version.stub(:breaks, ['floating']) do
      story.breaks.must_equal ['floating']
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

  it 'pulls the duration from the default_audio_version' do
    story.default_audio_version.stub(:default_audio_duration, 212) do
      story.duration.must_equal 212
    end
  end

  it 'pulls the default audio from the default_audio_version' do
    story.default_audio_version.stub(:as_default_audio, :audio) do
      story.default_audio.must_equal :audio
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
end
