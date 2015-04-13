# encoding: utf-8

class Api::AudioFilesController < Api::BaseController

  api_versions :v1

  filter_resources_by :audio_version_id

  # if the audio version is not set, and story is, set default av
  def resource
    @audio_file ||= super.tap do |r|
      if story && r.new_record?
        r.audio_version_id ||= story.default_audio_version.id
        r.account_id ||= story.account_id
      end
    end
  end

  def resources
    if story
      @audio_files ||= story_audio.page(params[:page])
    else
      super
    end
  end

  def story_audio
    story.default_audio_version.audio_files
  end

  def story
    @story ||= Story.find(params[:story_id]) if params[:story_id]
  end
end
