# encoding: utf-8

class PodcastEpisodeImportJob < ApplicationJob

  queue_as :cms_default

  def perform(podcast_episode_import)
    ActiveRecord::Base.connection_pool.with_connection do
      podcast_episode_import.import
    end
  end
end
