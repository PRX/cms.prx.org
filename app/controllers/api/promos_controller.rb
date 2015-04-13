# encoding: utf-8

class Api::PromosController < Api::BaseController

  api_versions :v1

  def resource
    super.tap do |af|
      if story && af && !af.audio_version_id
        af.audio_version_id = story.promos.id
      end
    end
  end

  def resources
    @promos ||= story.promos_audio
  end

  def story
    @story ||= Story.find(params[:story_id]) if params[:story_id]
  end

  def self.resource_class
    AudioFile
  end
end
