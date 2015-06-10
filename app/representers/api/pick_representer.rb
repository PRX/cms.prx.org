# encoding: utf-8

class Api::PickRepresenter < Api::BaseRepresenter

  property :id, writeable: false
  property :comment
  property :editors_title

  link :account do
    {
      href: api_account_path(represented.playlist.account),
      title: represented.playlist.account.name,
      profile: prx_model_uri(represented.playlist.account)
    } if represented.playlist && represented.playlist.account
  end
  embed :account, as: :account, item_class: Account, decorator: Api::Min::AccountRepresenter

  link :story do
    {
      href: api_story_path(represented.story),
      title: represented.story.title,
      profile: prx_model_uri(represented.story)
    } if represented.story
  end
  embed :story, as: :story, item_class: Story, decorator: Api::Min::StoryRepresenter
end
