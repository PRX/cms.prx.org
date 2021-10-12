# encoding: utf-8

class EpisodeImportJob < ApplicationJob
  queue_as :cms_podcast_import

  if ENV['PODCAST_IMPORT_QUEUE_NAME']
    queue_as ENV['PODCAST_IMPORT_QUEUE_NAME']
    self.queue_name_prefix = nil
  end

  def perform(episode_import)
    episode_import.import
  end
end
