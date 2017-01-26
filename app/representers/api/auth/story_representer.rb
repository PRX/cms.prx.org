# encoding: utf-8

class Api::Auth::StoryRepresenter < Api::StoryRepresenter
  # make sure "self" stays under authorization, because unpublished
  # stories won't exist under the public stories path
  def self_url(r)
    api_authorization_story_path(r)
  end

  link rel: :publish, writeable: false do
    {
      href: publish_api_authorization_story_path(represented)
    } if represented.published_at.nil?
  end

  link rel: :unpublish, writeable: false do
    {
      href: unpublish_api_authorization_story_path(represented)
    } if !represented.published_at.nil?
  end
end
