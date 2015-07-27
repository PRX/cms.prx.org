# encoding: utf-8

class Api::Min::AccountRepresenter < Api::BaseRepresenter

  property :id, writeable: false
  property :type
  property :name
  property :path
  property :short_name

  alternate_link

  link :address do
    api_account_address_path(represented.id) if represented.id
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
    {
      href: "#{api_account_stories_path(represented)}{?filters}",
      templated: true
    }
  end
  embed :stories, paged: true, item_class: Story, item_decorator: Api::Min::StoryRepresenter, zoom: false

  link :audio_files do
    {
      href: api_account_audio_files_path(represented)
    }
  end
end
