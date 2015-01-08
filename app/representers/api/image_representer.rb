# encoding: utf-8

class Api::ImageRepresenter < Api::BaseRepresenter

  property :id
  property :filename
  property :size
  property :caption
  property :credit

  link :enclosure do
    {
      href: represented.public_url(version: 'medium'),
      type: represented.content_type || 'image'
    } if represented.id
  end
end
