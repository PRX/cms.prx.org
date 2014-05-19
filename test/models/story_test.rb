require 'test_helper'
require 'story'

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

end
