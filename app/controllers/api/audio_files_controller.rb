class Api::AudioFilesController < Api::BaseController

  api_versions :v1

  filter_resources_by :audio_version_id

  def resources
    super
    # return super unless params[:story_id]
    # self.resources = Story.find(params[:story_id]).default_audio_version.audio_files.page(params[:page])
  end

end
