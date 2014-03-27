# encoding: utf-8

class Api::AccountRepresenter < Api::BaseRepresenter

  property :id
  property :type
  property :name
  property :path

  link :address do
    api_address_path(represented.address) if represented.address
  end
  embed :address, class: Address, decorator: Api::AddressRepresenter, zoom: true

  link :image do
    {
      href:    polymorphic_path([:api, represented.image]),
      title:   represented.image.filename,
      profile: prx_model_uri(represented.image)
    } if represented.image
  end
  embed :image, class: Image, decorator: Api::ImageRepresenter, zoom: true
  
  link :opener do
    {
      href: api_user_path(represented.opener),
      title: represented.opener.login
    } if represented.opener
  end
  embed :opener, class: User, decorator: Api::Min::UserRepresenter

  link :stories do
    api_account_stories_path(represented)
  end
  embed :stories, as: :stories, paged: true, item_class: Story, item_decorator: Api::Min::StoryRepresenter, zoom: true

end
