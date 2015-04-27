# encoding: utf-8

class Api::PromosController < Api::BaseController

  api_versions :v1

  def resources_base
    story.promos_audio
  end

  def story
    @story ||= Story.find(params[:story_id])
  end

  def self.resource_class
    AudioFile
  end
end
