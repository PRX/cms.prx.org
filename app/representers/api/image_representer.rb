# encoding: utf-8

class Api::ImageRepresenter < Api::BaseRepresenter

  def self_url(represented)
    if represented.is_a?(StoryImage)
      api_story_story_image_path(represented.story, represented)
    elsif represented.is_a?(SeriesImage)
      api_series_series_image_path(represented.series, represented)
    elsif represented.is_a?(AccountImage)
      api_account_account_image_path(represented.account, represented)
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

  # provide either an accessible url or the file itself for upload
  property :upload, readable: false
  property :file, readable: false

  link :enclosure do
    {
      href: represented.public_url(version: 'medium'),
      type: represented.content_type || 'image'
    } if represented.id
  end
end
