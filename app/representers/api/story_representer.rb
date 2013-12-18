class Api::StoryRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL

  property :title

  link :self do
    api_story_path(represented)
  end
end
