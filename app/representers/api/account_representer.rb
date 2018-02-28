# encoding: utf-8

class Api::AccountRepresenter < Api::BaseRepresenter
  property :id, writeable: false
  property :type
  property :name
  property :path
  property :short_name
  property :description

  alternate_link

  link :address do
    api_account_address_path(represented.id) if represented.id
  end
  embed :address, class: Address, decorator: Api::AddressRepresenter

  link :image do
    if represented.id && represented.image
      {
        href: api_account_account_image_path(represented),
        title: represented.image.filename
      }
    end
  end
  embed :image, class: Image, decorator: Api::ImageRepresenter

  link 'create-image' do
    if represented.id && !represented.image
      {
        href: api_account_account_image_path(represented),
        title: 'Create an image'
      }
    end
  end

  link rel: :opener, writeable: true do
    if represented.opener && represented.opener.id
      {
        href: api_user_path(represented.opener),
        title: represented.opener.login
      }
    end
  end
  embed :opener, class: User, decorator: Api::Min::UserRepresenter, zoom: false

  link :stories do
    if represented.id
      {
        href: "#{api_account_stories_path(represented)}#{index_url_params}",
        templated: true,
        count: represented.public_stories.count
      }
    end
  end
  embed :public_stories,
        as: :stories,
        paged: true,
        item_class: Story,
        item_decorator: Api::Min::StoryRepresenter

  link :series do
    if represented.id
      {
        href: "#{api_account_series_index_path(represented)}#{index_url_params}",
        templated: true,
        count: represented.series.count
      }
    end
  end
  embed :series, paged: true, item_class: Series, item_decorator: Api::Min::SeriesRepresenter

  link :audio_files do
    if represented.id
      {
        href: api_account_audio_files_path(represented)
      }
    end
  end

  links :external do
    represented.websites.map(&:as_link)
  end
end
