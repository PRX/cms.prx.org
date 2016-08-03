class ImageCallbackWorker
  include Shoryuken::Worker

  shoryuken_options queue: "#{ENV['RAILS_ENV']}_cms_image_callback"

  def perform(sqs_msg, job)
    image = case job['type']
            when 'account_images'
              AccountImage.find(job['id'])
            when 'piece_images'
              StoryImage.find(job['id'])
            when 'series_images'
              SeriesImage.find(job['id'])
            when 'user_images'
              UserImage.find(job['id'])
            else
              Shoryuken.logger.error("Unknown image type for message: #{job}")
              return
            end

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
  end

end
