# encoding: utf-8

class Api::ImageRepresenter < Api::BaseRepresenter

  property :id
  property :filename
  property :size

  link :enclosure do
    {
      href: represented.public_url,
      type: represented.content_type || 'image'
    }
  end

end
