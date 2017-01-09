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
    mock_story_distro = MiniTest::Mock.new
    mock_story_distro.expect(:tap, mock_story_distro)
    mock_story_distro.expect(:distribute!, true)
    mock_distro = MiniTest::Mock.new
    mock_distro.expect(:create, mock_story_distro, [Hash])
    distribution.stub(:story_distribution_class, mock_distro) do
      story_distribution = distribution.create_story_distribution(story)
    end
  end
end
