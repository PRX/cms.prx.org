require 'test_helper'
require 'minitest/mock'

describe Distribution do
  let(:distribution) { create(:distribution) }
  let(:story) { create(:story) }

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
    distribution.properties["explicit"].must_equal "clean"
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
end
