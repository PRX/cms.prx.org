# encoding: utf-8

class EpisodeImportJob < ApplicationJob
  queue_as ENV['SQS_PODCAST_IMPORT_QUEUE_NAME']

  def perform(episode_import)
    episode_import.import
  end
end
