class ImageCallbackWorker
  include Shoryuken::Worker

  class UnknownImageTypeError < StandardError; end

  shoryuken_options queue: "#{ENV['RAILS_ENV']}_cms_image_callback"

  def perform(_sqs_msg, job)
    image = find_image(job['type'], job['id'])
    image.filename = job['name']
    image.size = job['size']
    image.width = job['width']
    image.height = job['height']
    image.aspect_ratio = image.width / image.height.to_f if image.width && image.height

    mime_type = MIME::Types.type_for(job['format']).first.try(:content_type)
    image.content_type = mime_type || job['format']

    if !job['downloaded']
      image.status = Image::NOTFOUND
    elsif !job['valid']
      image.status = Image::INVALID
    elsif !job['resized']
      image.status = Image::FAILED
    else
      image.upload_path = nil
      image.status = Image::COMPLETE
    end

    Shoryuken.logger.info("Updating #{job['type']}[#{image.id}]: status => #{image.status}")
    image.save!
  rescue ActiveRecord::RecordNotFound
    Shoryuken.logger.error("Record #{job['type']}[#{job['id']}] not found")
  rescue UnknownImageTypeError
    Shoryuken.logger.error("Unknown image type for message: #{job}")
  end

  def find_image(type, id)
    case type
    when 'account_images'
      AccountImage.find(id)
    when 'piece_images'
      StoryImage.find(id)
    when 'series_images'
      SeriesImage.find(id)
    when 'user_images'
      UserImage.find(id)
    else
      raise UnknownImageTypeError.new
    end
  end

end
