# encoding: utf-8

class Api::PickRepresenter < Api::BaseRepresenter

  property :id
  property :comment
  property :editors_title

  link :pick_list do
    {
      href: api_pick_list_path(represented.pick_list),
      title: represented.pick_list,
      profile: prx_model_uri(represented.pick_list)
    }
  end

  link :account do
    {
      href: api_account_path(represented.pick_list.account),
      title: represented.pick_list.account.name,
      profile: prx_model_uri(represented.pick_list.account)
    }
  end
  embed :account, as: :account, item_class: Account, decorator: Api::Min::AccountRepresenter, zoom: true

  link :story do
    {
      href: api_story_path(represented.story),
      title: represented.story.title,
      profile: prx_model_uri(represented.story)
    }
  end
  embed :story, as: :story, item_class: Story, decorator: Api::Min::StoryRepresenter, zoom: true

end

