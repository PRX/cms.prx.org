require 'test_helper'

describe Distributions::PodcastDistribution do

  let(:distribution) { create(:podcast_distribution) }

  it 'creates the podcast on feeder' do
    distribution.account.wont_be_nil
    distribution.add_podcast_to_feeder
  end
end
