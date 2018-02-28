# encoding: utf-8

class Api::PickRepresenter < Api::BaseRepresenter
  property :id, writeable: false
  property :comment
  property :editors_title

  link :account do
    if represented.playlist && represented.playlist.account
      {
        href: api_account_path(represented.playlist.account),
        title: represented.playlist.account.name,
        profile: model_uri(represented.playlist.account)
      }
    end
  end
  embed :account, as: :account, item_class: Account, decorator: Api::Min::AccountRepresenter

  link :story do
    if represented.story
      {
        href: api_story_path(represented.story),
        title: represented.story.title,
        profile: model_uri(represented.story)
      }
    end
  end
  embed :story, as: :story, item_class: Story, decorator: Api::Min::StoryRepresenter
end
