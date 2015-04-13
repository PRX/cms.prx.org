# encoding: utf-8

class Api::PromosController < Api::BaseController

  api_versions :v1

  def resource
    super.tap do |af|
      if story && af.try(:new_record?)
        af.audio_version_id ||= story.promos.id
        af.account_id ||= story.account_id
      end
    end
  end

  def resources
    @promos ||= story.try(:promos_audio)
  end

  def story
    @story ||= Story.find(params[:story_id]) if params[:story_id]
  end

  def self.resource_class
    AudioFile
  end
end
