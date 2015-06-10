# encoding: utf-8

class Api::AccountRepresenter < Api::BaseRepresenter

  property :id, writeable: false
  property :type
  property :name
  property :path
  property :short_name
  property :description

  link :address do
    api_account_address_path(represented.id) if represented.id
  end
  embed :address, class: Address, decorator: Api::AddressRepresenter

  link :image do
    {
      href:  api_account_account_image_path(represented),
      title: represented.image.try(:filename)
    } if represented.id
  end
  embed :image, class: Image, decorator: Api::ImageRepresenter

  link rel: :opener, writeable: true do
    {
      href:  api_user_path(represented.opener),
      title: represented.opener.login
    } if represented.opener && represented.opener.id
  end
  embed :opener, class: User, decorator: Api::Min::UserRepresenter, zoom: false

  link :stories do
    {
      href: "#{api_account_stories_path(represented)}{?page,per,zoom,filters}",
      templated: true,
      count: represented.stories.count
    } if represented.id
  end
  embed :stories, paged: true, item_class: Story, item_decorator: Api::Min::StoryRepresenter

  links :external do
    represented.websites.map(&:as_link)
  end
end
