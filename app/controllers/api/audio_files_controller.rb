# encoding: utf-8

class Api::AudioFilesController < Api::BaseController

  api_versions :v1

  filter_resources_by :audio_version_id

  def resources
    return super unless story
    self.resources = story.default_audio_version.audio_files.page(params[:page])
  end

  def story
    @story ||= Story.find(params[:story_id]) if params[:story_id]
  end
end
