class StorySerializer < ActiveModel::Serializer
  attributes :self, :title, :short_description, :description

  def self
    api_story_url(object)
  end

  def short_description
    object.short_description.truncate(140, separator: ' ')
  end
end
