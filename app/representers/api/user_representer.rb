# encoding: utf-8

class Api::UserRepresenter < Api::BaseRepresenter

  property :id
  property :first_name
  property :last_name
  property :login

  link :accounts do
    {
      href: api_user_accounts_path(represented),
      count: represented.accounts.count
    } if represented.id
  end
  embed :accounts, paged: true, item_class: Account, item_decorator: Api::Min::AccountRepresenter, zoom: false

  link rel: :image, writeable: true do
    api_user_image_path(represented.image) if represented.image
  end
  embed :image, class: Image, decorator: Api::ImageRepresenter
end
