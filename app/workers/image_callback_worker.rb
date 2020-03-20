class ImageCallbackWorker
  include Shoryuken::Worker
  include ValidityFlag
  include Announce::Publisher

  class UnknownImageTypeError < StandardError; end

  shoryuken_options queue: "#{ENV['RAILS_ENV']}_cms_image_callback"

  def perform(_sqs_msg, job)
    image = nil

    if job[:JobResult]
      image = Image.by_porter_job_id(job[:JobResult][:Job][:Id])
      if image.present?
        job_results = job[:JobResult][:Result]
        copy_task_result = job_results.find{|result| result[:Task] === 'Copy' }
        if copy_task_result.present?
          image.filename = File.basename(copy_task_result[:ObjectKey])
        end

        inspect_task_result = job_results.find{|result| result[:Task] === 'Inspect' }
        if inspect_task_result.present?
          image.size = inspect_task_result[:Inspection][:Size]
          image.width = inspect_task_result[:Inspection][:Image][:Width]
          image.height = inspect_task_result[:Inspection][:Image][:Height]
          image.aspect_ratio = image.width / image.height.to_f if image.width && image.height
          image.content_type = inspect_task_result[:Inspection][:MIME]
        end

        if copy_task_result.blank?
          image.status = NOTFOUND
        elsif inspect_task_result.blank? || image.content_type.split('/')[0] != 'image'
          image.status = INVALID
        elsif job_results.find_all{|result| result[:Task] === 'Image' }.present?
          image.status = COMPLETE
        else
          image.status = FAILED
        end

        image.save!
          
      end
    else
      image = find_image(job['type'], job['id'])
      image.filename = job['name']
      image.size = job['size']
      image.width = job['width']
      image.height = job['height']
      image.aspect_ratio = image.width / image.height.to_f if image.width && image.height

      mime_type = MIME::Types.type_for(job['format'] || '').first.try(:content_type)
      image.content_type = mime_type || job['format']

      if !job['downloaded']
        image.status = NOTFOUND
      elsif !job['valid']
        image.status = INVALID
      elsif !job['resized']
        image.status = FAILED
      else
        image.status = COMPLETE
      end

      Shoryuken.logger.info("Updating #{job['type']}[#{image.id}]: status => #{image.status}")
      image.save!
    end

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
end
