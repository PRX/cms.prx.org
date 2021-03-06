# encoding: utf-8

class Api::ProducerRepresenter < Api::BaseRepresenter
  property :id, writeable: false
  property :user_id
  property :name

  def self_url(represented)
    api_story_producer_path(represented.story, represented)
  end

  link :user do
    {
      href: api_user_path(represented.user),
      title: represented.user.login
    } if represented.user
  end
end
