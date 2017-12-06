require 'test_helper'
require 'minitest/mock'

describe PodcastEpisodeImportJob do

  let(:job) { PodcastEpisodeImportJob.new }

  it 'import that episode' do
    episode_import = MiniTest::Mock.new
    episode_import.expect(:import, true)
    job.perform(episode_import).must_equal true
  end
end
