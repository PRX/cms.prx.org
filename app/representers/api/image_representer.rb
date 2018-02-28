# encoding: utf-8

class Api::ImageRepresenter < Api::BaseRepresenter
  include NestedImage

  def self_url(represented)
    nested_image_path(represented) || super
  end

  property :id, writeable: false
  property :filename, writeable: false
  property :size
  property :width
  property :height
  property :caption
  property :credit
  property :status, writeable: false
  property :purpose

  # provide an accessible url to the image media file for upload
  property :upload, readable: false

  link :enclosure do
    if represented.id
      {
        href: represented.public_url(version: 'medium'),
        type: represented.content_type || 'image'
      }
    end
  end

  link :original do
    if represented.id
      {
        href: represented.public_url(version: 'original'),
        type: represented.content_type || 'image'
      }
    end
  end
end
