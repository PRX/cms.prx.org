class Api::PromosController < Api::BaseController

  api_versions :v1

  def resource
    @promo ||= if (params[:story_id] && params[:id])
      Story.find(params[:story_id]).promos.audio_files.find(params[:id])
    else
      Story.find(params[:story_id]).promos.audio_files.build
    end
  end

  def resources
    @promos ||= Story.find(params[:story_id]).promos.audio_files.page(params[:page])
  end

  def self.resource_class
    AudioFile
  end

end
