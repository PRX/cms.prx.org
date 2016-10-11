# encoding: utf-8

class Api::UserRepresenter < Api::BaseRepresenter
  property :id, writeable: false
  property :first_name
  property :last_name
  property :login

  link :accounts do
    {
      href: "#{api_user_accounts_path(represented)}#{index_url_params}",
      templated: true,
      count: represented.accounts.count
    } if represented.id
  end
  embed :accounts,
        paged: true,
        item_class: Account,
        item_decorator: Api::Min::AccountRepresenter,
        zoom: false

  link :image do
    {
      href:  api_user_user_image_path(represented),
      title: represented.image.filename
    } if represented.id && represented.image
  end
  embed :image, class: Image, decorator: Api::ImageRepresenter

  link 'create-image' do
    {
      href: api_user_user_image_path(represented),
      title: 'Create an image'
    } if represented.id && !represented.image
  end
end
