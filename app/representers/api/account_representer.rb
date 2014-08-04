# encoding: utf-8

class Api::AccountRepresenter < Api::BaseRepresenter

  property :id
  property :type
  property :name
  property :path
  property :description
  property :short_name

  link :address do
    api_address_path(represented.address) if represented.address
  end
  embed :address, class: Address, decorator: Api::AddressRepresenter

  link :image do
    {
      href:    polymorphic_path([:api, represented.image]),
      title:   represented.image.filename,
      profile: prx_model_uri(represented.image)
    } if represented.image
  end
  embed :image, class: Image, decorator: Api::ImageRepresenter

  link :opener do
    {
      href: api_user_path(represented.opener),
      title: represented.opener.login
    } if represented.opener
  end
  embed :opener, class: User, decorator: Api::Min::UserRepresenter, zoom: false

  link :stories do
    api_account_stories_path(represented)
  end
  embed :stories, as: :stories, paged: true, item_class: Story, item_decorator: Api::Min::StoryRepresenter

  links :external do
    represented.websites.map(&:as_link)
  end
end
