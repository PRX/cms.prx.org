# encoding: utf-8

class PodcastImportJob < ApplicationJob
  queue_as :cms_podcast_import

  if ENV['PODCAST_IMPORT_QUEUE_NAME']
    queue_as ENV['PODCAST_IMPORT_QUEUE_NAME']
    self.queue_name_prefix = nil
  end

  def perform(podcast_import, import_series = true)
    if import_series
      podcast_import.import_series!
    end
    podcast_import.import_episodes!
  end
end
