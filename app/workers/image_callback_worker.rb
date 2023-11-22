class ImageCallbackWorker
  include Shoryuken::Worker
  include ValidityFlag
  include Announce::Publisher

  class UnknownImageTypeError < StandardError; end
  class ImageProcessingError < StandardError
    attr_reader :status
    def initialize(status)
      @status = status
    end
  end

  shoryuken_options queue: Image::CALLBACK_QUEUE

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
    job_result = job['JobResult']
    image = GlobalID::Locator.locate(job_result['Job']['Id'])
    if image.present?
      image.with_lock do
        begin
          callback_copy(image, job_result)
          callback_analyze(image, job_result)
          callback_thumb(image, job_result)
        rescue ImageProcessingError => error
          image.status = error.status
        end

        image.save!
        announce_image_changed(image)
      end
    end
  rescue ActiveRecord::RecordNotFound
    Shoryuken.logger.error("Record #{job_result['Job']['Id']} not found")
  end

  def callback_copy(image, job_result)
    copy_task_result = job_result['TaskResults'].try(:detect) { |result| result['Task'] == 'Copy' }

    if copy_task_result.present?
      image.filename = File.basename(copy_task_result['ObjectKey'])
    else
      raise ImageProcessingError.new(NOTFOUND)
    end
  end

  def callback_analyze(image, job_result)
    inspect_task_result = job_result['TaskResults'].try(:detect) do |result|
      result['Task'] == 'Inspect'
    end

    if inspect_task_result.present?
      image.size = inspect_task_result['Inspection']['Size']
      image.width = inspect_task_result['Inspection']['Image']['Width']
      image.height = inspect_task_result['Inspection']['Image']['Height']
      image.aspect_ratio = image.width / image.height.to_f if image.width && image.height
      image.content_type = inspect_task_result['Inspection']['MIME']
    else
      raise ImageProcessingError.new(INVALID)
    end
  end

  def callback_thumb(image, job_result)
    resize_task_results = job_result['TaskResults'].try(:select) do |result|
      result['Task'] == 'Image'
    end
    if resize_task_results.length >= ImageUploader.version_formats.length
      image.status = COMPLETE
    else
      raise ImageProcessingError.new(FAILED)
    end
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
