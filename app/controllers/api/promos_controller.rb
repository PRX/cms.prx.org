# encoding: utf-8

class Api::PromosController < Api::BaseController

  api_versions :v1

  def resource
    @promo ||= if story && params[:id]
      story.promos.audio_files.find(params[:id])
    else
      story.promos.audio_files.build
    end
  end

  def resources
    @promos ||= story.promos.audio_files.page(params[:page])
  end

  def story
    @story ||= Story.find(params[:story_id]) if params[:story_id]
  end

  def self.resource_class
    AudioFile
  end
end
