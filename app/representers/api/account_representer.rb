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
    {
      href: api_account_account_image_path(represented),
      title: represented.image.try(:filename)
    } if represented.id
  end
  embed :image, class: Image, decorator: Api::ImageRepresenter

  link rel: :opener, writeable: true do
    {
      href: api_user_path(represented.opener),
      title: represented.opener.login
    } if represented.opener && represented.opener.id
  end
  embed :opener, class: User, decorator: Api::Min::UserRepresenter, zoom: false

  link :stories do
    {
      href: "#{api_account_stories_path(represented)}#{index_url_params}",
      templated: true,
      count: represented.public_stories.count
    } if represented.id
  end
  embed :public_stories,
        as: :stories,
        paged: true,
        item_class: Story,
        item_decorator: Api::Min::StoryRepresenter

  link :series do
    {
      href: "#{api_account_series_index_path(represented)}#{index_url_params}",
      templated: true,
      count: represented.series.count
    } if represented.id
  end
  embed :series, paged: true, item_class: Series, item_decorator: Api::Min::SeriesRepresenter

  link :audio_files do
    {
      href: api_account_audio_files_path(represented)
    } if represented.id
  end

  links :external do
    represented.websites.map(&:as_link)
  end
end
