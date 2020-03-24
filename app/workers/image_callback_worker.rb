class ImageCallbackWorker
  include Shoryuken::Worker
  include ValidityFlag
  include Announce::Publisher

  class UnknownImageTypeError < StandardError; end

  shoryuken_options queue: Image::CALLBACK_QUEUE_NAME

  # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
  def perform(_sqs_msg, job)
    if job['JobResult']
      perform_porter_job_callback(job)
    elsif job['type'] && job['id']
      perform_lambda_job_callback(job)
    end
  end

  def announce_image_changed(image)
    Shoryuken.logger.info("Updating #{image.class.name}[#{image.id}]: status => #{image.status}")
    # announce the image changes on its story or series
    if image.is_a?(StoryImage)
      story = image.story
      story.with_lock do
        announce(:story, :update, Api::Msg::StoryRepresenter.new(story).to_json)
      end
    elsif image.is_a?(SeriesImage)
      series = image.series
      series.with_lock do
        announce(:series, :update, Api::Msg::SeriesRepresenter.new(series).to_json)
      end
    end
  end

  def perform_porter_job_callback(job)
    job_id, task_type = job['JobResult']['Job']['Id'].split(':')
    image = Image.by_porter_job_id(job_id)
    if image.present?
      case task_type
      when 'copy'
        callback_copy(image, job['JobResult'])
      when 'analyze'
        callback_analyze(image, job['JobResult'])
      when 'resize'
        callback_resize(image, job['JobResult'])
      else
        return nil
      end
      return image
    end
  end

  def callback_copy(image, job_result)
    if job_result['Error']
      image.status = NOTFOUND

      announce_image_changed(image)
    else
      copy_task_result = job_result['Result'].detect { |result| result['Task'] == 'Copy' }
      image.filename = File.basename(copy_task_result['ObjectKey'])
      
      image.analyze_file!
    end

    image.save!
  end

  def callback_analyze(image, job_result)
    if job_result['Error']
      image.status = INVALID
      announce_image_changed(image)
    else
      inspect_task_result = job_result['Result'].detect { |result| result['Task'] == 'Inspect' }
      if inspect_task_result
        image.size = inspect_task_result['Inspection']['Size']
        image.width = inspect_task_result['Inspection']['Image']['Width']
        image.height = inspect_task_result['Inspection']['Image']['Height']
        image.aspect_ratio = image.width / image.height.to_f if image.width && image.height
        image.content_type = inspect_task_result['Inspection']['MIME']
        
        image.generate_thumbnails!(inspect_task_result['Inspection']['Image']['Format'])
      end
    end

    image.save!
  end

  def callback_resize(image, job_result)
    if job_result['Error']
      image.status = FAILED
    else
      image.status = COMPLETE
    end

    image.save!
    announce_image_changed(image)
  end

  # START cms-image-lambda behavior

  def perform_lambda_job_callback(job)
    image = find_image(job['type'], job['id'])
    image.filename = job['name']
    image.size = job['size']
    image.width = job['width']
    image.height = job['height']
    image.aspect_ratio = image.width / image.height.to_f if image.width && image.height

    mime_type = MIME::Types.type_for(job['format'] || '').first.try(:content_type)
    image.content_type = mime_type || job['format']

    image.status = if !job['downloaded']
                     NOTFOUND
                   elsif !job['valid']
                     INVALID
                   elsif !job['resized']
                     FAILED
                   else
                     COMPLETE
                   end

    image.save!
    announce_image_changed(image)

  rescue ActiveRecord::RecordNotFound
    Shoryuken.logger.error("Record #{job['type']}[#{job['id']}] not found")
  rescue UnknownImageTypeError
    Shoryuken.logger.error("Unknown image type for message: #{job}")
  end

  def find_image(type, id)
    type = 'story_images' if type == 'piece_images'
    type_class = nil
    begin
      type_class = type.camelize.singularize.constantize
    rescue NameError
      raise UnknownImageTypeError.new
    end
    type_class.find(id)
  end

  # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity
end
