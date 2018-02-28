require 'test_helper'
require 'minitest/mock'

class TestStoryDistribution < StoryDistribution
  attr_accessor :distributed, :published

  def distributed?; distributed; end

  def published?; published; end

  def distribute!; self.distributed = true; end

  def publish!; self.published = true; end
end

describe Distribution do
  let(:story_distribution) { create(:story_distribution, url: nil) }
  let(:distribution) { story_distribution.distribution }
  let(:story) { story_distribution.story }

  it 'has a table defined' do
    Distribution.table_name.must_equal 'distributions'
  end

  it 'has an owner' do
    distribution.owner.wont_be_nil
  end

  it 'has an account' do
    distribution.account.wont_be_nil
    distribution.account.must_equal distribution.owner.account
  end

  it 'has properties' do
    distribution.properties.wont_be_nil
    distribution.properties['explicit'].must_equal 'clean'
  end

  it 'can be created with valid attributes' do
    distribution.must_be :valid?
  end

  it 'returns story distribution class' do
    distribution.story_distribution_class.must_equal StoryDistribution
  end

  it 'creates and distributes for story' do
    mock_distro = MiniTest::Mock.new
    mock_story_distro = MiniTest::Mock.new

    mock_distro.expect(:create, mock_story_distro, [Hash])
    mock_story_distro.expect(:tap, mock_story_distro)
    mock_story_distro.expect(:distribute!, true)

    distribution.stub(:story_distribution_class, mock_distro) do
      distribution.create_story_distribution(story)
    end
  end

  it 'updates templates with an array of ids' do
    avt1 = create(:audio_version_template, series_id: distribution.distributable_id)
    avt2 = create(:audio_version_template, series_id: distribution.distributable_id)
    avt3 = create(:audio_version_template)
    create(:distribution_template, distribution: distribution, audio_version_template: avt1)

    distribution.audio_version_template_ids.must_equal [avt1.id]
    distribution.set_template_ids([avt2.id, avt3.id, 0])
    distribution.save
    distribution.audio_version_template_ids.sort.must_equal [avt2.id]
  end

  describe 'checks if distributions published' do
    before do
      story.update_attribute(:published_at, 2.minutes.ago)
    end

    it 'finds recently published stories' do
      stories = Distribution.recently_published_stories(60, 3600)
      stories.count.must_equal 1
    end

    it 'attempts to distribute stories' do
      tsd = TestStoryDistribution.new(story: story, distribution: distribution)
      tsd.wont_be :published?
      tsd.wont_be :distributed?
      story.distributions = [tsd]

      Distribution.stub(:recently_published_stories, [story]) do
        Distribution.check_published!
      end

      tsd.must_be :published?
      tsd.must_be :distributed?
    end
  end
end
