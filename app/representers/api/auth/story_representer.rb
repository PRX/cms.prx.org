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

  link :audio do
    {
      href: api_authorization_audio_files_path(represented.id),
      count: represented.default_audio.count
    } if represented.id
  end
  embed :default_audio,
        as: :audio,
        paged: true,
        item_class: AudioFile,
        item_decorator: Api::Auth::AudioFileRepresenter,
        per: :all
end
