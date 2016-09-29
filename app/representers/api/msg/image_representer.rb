# encoding: utf-8

#
# Representer for Announce messaging
#
class Api::Msg::ImageRepresenter < Api::BaseRepresenter
  def self_url(represented)
    if represented.is_a?(StoryImage)
      api_story_story_image_path(represented.story, represented)
    elsif represented.is_a?(SeriesImage)
      api_series_series_image_path(represented.series)
    elsif represented.is_a?(AccountImage)
      api_account_account_image_path(represented.account)
    elsif represented.is_a?(UserImage)
      api_user_user_image_path(represented.user)
    else
      super
    end
  end

  property :id, writeable: false
  property :filename, writeable: false
  property :size
  property :caption
  property :credit
  property :status, writeable: false

  # parent id (useful to identify soft-deleted images in s3)
  property :piece_id, writeable: false, if: -> (*) { is_a?(StoryImage) }
  property :series_id, writeable: false, if: -> (*) { is_a?(SeriesImage) }
  property :account_id, writeable: false, if: -> (*) { is_a?(AccountImage) }
  property :user_id, writeable: false, if: -> (*) { is_a?(UserImage) }

  # the newly uploaded file
  property :upload_path

  # destination for the uploaded file
  property :fixerable_final_path, as: :destination_path
end
