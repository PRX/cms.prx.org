# encoding: utf-8

class Api::AudioFilesController < Api::BaseController

  api_versions :v1

  filter_resources_by :audio_version_id

  # if the audio version is not set, and story is, set default av
  def resource
    r = super
    if !r.audio_version_id && story
      r.audio_version_id = story.default_audio_version.id
    end
    r
  end

  def resources
    return super unless story
    @audio_files ||= story.default_audio_version.audio_files.page(params[:page])
  end

  def story
    @story ||= Story.find(params[:story_id]) if params[:story_id]
  end
end
