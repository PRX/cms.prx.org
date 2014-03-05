# encoding: utf-8

class Api::UserRepresenter < Api::BaseRepresenter

  property :id
  property :first_name
  property :last_name
  property :login

  link :accounts do
    api_user_accounts_path(represented)
  end

  link :image do
    api_user_image_path(represented.image) if represented.image
  end
  embed :image, class: Image, decorator: Api::ImageRepresenter, zoom: :always

end
