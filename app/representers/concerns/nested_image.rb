# encoding: utf-8

require 'active_support/concern'

module NestedImage
  extend ActiveSupport::Concern

  def nested_image_path(represented)
    if represented.is_a?(StoryImage)
      api_story_story_image_path(represented.story, represented)
    elsif represented.is_a?(SeriesImage)
      api_series_series_image_path(represented.series)
    elsif represented.is_a?(AccountImage)
      api_account_account_image_path(represented.account)
    elsif represented.is_a?(UserImage)
      api_user_user_image_path(represented.user)
    end
  end
end
