# encoding: utf-8

class Api::StoryDistributionRepresenter < Api::BaseRepresenter
  property :id, writeable: false
  property :guid
  property :url
  property :kind
  hash :properties

  def self_url(story_distribution)
    api_story_story_distribution_path(story_distribution.story, story_distribution)
  end

  link :story do
    if represented.story
      {
        href: api_story_path(represented.story),
        title: represented.story.title,
        profile: model_uri(represented.story)
      }
    end
  end
  embed :story,
        as: :story,
        item_class: Story,
        decorator: Api::Min::StoryRepresenter,
        zoom: false
end
