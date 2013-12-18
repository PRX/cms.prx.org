class Api::StoriesRepresenter < Roar::Decorator
  include Api::PagedCollectionRepresenter

  collection :items, as: :stories, embedded: true, class: Story, decorator: Api::StoryRepresenter
end
