# encoding: utf-8

class Api::AudioFilesController < Api::BaseController
  api_versions :v1

  filter_resources_by :audio_version_id, :account_id

  announce_actions subject: :audio

  def original
    authorize show_resource
    redirect_to show_resource.asset_url(original_params)
  end

  def original_params
    params.permit(:expiration)
  end

  # if the audio version is not set, and story is, set default av
  def create_resource
    super.tap do |af|
      if story
        af.audio_version_id ||= story.default_audio_version.id
        af.account_id ||= story.account_id
      end
      if af.audio_version_id && !af.account_id
        af.account_id ||= af.audio_version.story.account_id
      end
    end
  end

  def resources_base
    story.try(:default_audio) || super
  end

  def story
    @story ||= Story.find(params[:story_id]) if params[:story_id]
  end
end
