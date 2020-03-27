# encoding: utf-8

require 'aws-sdk'
require 'securerandom'

class Image < BaseModel

  self.abstract_class = true

  include PublicAsset
  include Fixerable
  include ValidityFlag

  SNS_CLIENT = if ENV['PORTER_SNS_TOPIC_ARN']
                 Aws::SNS::Client.new
               elsif !Rails.env.test?
                 Rails.logger.warn('No Porter SNS topic provided - Porter jobs will be skipped.')
                 nil
               end

  CALLBACK_QUEUE_NAME = "#{ENV['RAILS_ENV']}_cms_image_callback".freeze
  SQS_QUEUE_URI = URI::HTTPS.build(
    host: "sqs.#{ENV['AWS_REGION']}.amazonaws.com",
    path: "/#{ENV['AWS_ACCOUNT_ID']}/#{CALLBACK_QUEUE_NAME}"
  ).to_s.freeze

  def self.profile
    order("field(purpose, '#{Image::PROFILE}') desc, created_at desc").first
  end

  def self.thumbnail
    order("field(purpose, '#{Image::THUMBNAIL}') desc, created_at desc").first
  end

  def self.by_porter_job_id(porter_job_id)
    [AccountImage, SeriesImage, StoryImage, UserImage].each do |klass|
      result = klass.find_by(porter_job_id: porter_job_id)
      return result if result.present?
    end
    nil
  end

  alias_attribute :upload, :upload_path

  mount_uploader :file, ImageUploader, mount_on: :filename
  skip_callback :commit, :after, :remove_file! # don't remove s3 file
  fixerable_upload :upload, :file

  before_validation do
    if upload
      self.status ||= UPLOADED
    end
  end

  # for backwards compatibility, null statuses are considered final
  def fixerable_final?
    ![FAILED, NOTFOUND, UPLOADED, INVALID].include?(status)
  end

  def complete?
    status == COMPLETE || status.nil?
  end

  def self.policy_class
    ImagePolicy
  end

  def copy_upload!
    return false if complete? || !SNS_CLIENT.present?

    Image.transaction do
      update_attribute :porter_job_id, SecureRandom.uuid
      publish_porter_sns(
        Job: {
          Id: "#{porter_job_id}:copy",
          Source: {
            Mode: 'HTTP',
            URL: asset_url
          },
          Tasks: [
            {
              Type: 'Copy',
              Mode: 'AWS/S3',
              BucketName: ENV['AWS_BUCKET'],
              ObjectKey: "#{fixerable_final_path}/#{filename}"
              ContentType: 'REPLACE',
              Parameters: {
                ContentDisposition: "attachment; filename=\"#{filename}\""
              }
            }
          ],
          Callbacks: [
            {
              Type: 'AWS/SQS',
              Queue: SQS_QUEUE_URI
            }
          ]
        }
      )
    end
  end

  def analyze_file!
    return false if complete? || !SNS_CLIENT.present?

    Image.transaction do
      update_attribute :porter_job_id, SecureRandom.uuid
      publish_porter_sns(
        Job: {
          Id: "#{porter_job_id}:analyze",
          Source: {
            Mode: 'AWS/S3',
            BucketName: ENV['AWS_BUCKET'],
            ObjectKey: file.path
          },
          Tasks: [
            { Type: 'Inspect' }
          ],
          Callbacks: [
            {
              Type: 'AWS/SQS',
              Queue: SQS_QUEUE_URI
            }
          ]
        }
      )
    end
  end

  def generate_thumbnails!(format)
    return false if complete?

    Image.transaction do
      update_attribute :porter_job_id, SecureRandom.uuid
      publish_porter_sns(
        Job: {
          Id: "#{porter_job_id}:resize",
          Source: {
            Mode: 'AWS/S3',
            BucketName: ENV['AWS_BUCKET'],
            ObjectKey: file.path
          },
          Tasks: resize_tasks(format),
          Callbacks: [
            {
              Type: 'AWS/SQS',
              Queue: SQS_QUEUE_URI
            }
          ]
        }
      )
    end
  end

  def remove!; end

  private

  def resize_tasks(format)
    ImageUploader.version_formats.map do |(name, dimensions)|
      derivative = file.public_send(name).path
      {
        Type: 'Image',
        Format: format,
        Metadata: 'PRESERVE',
        Resize: {
          Fit: name == 'square' ? 'cover' : 'inside',
          Height: dimensions[1],
          Position: 'centre',
          Width: dimensions[0]
        },
        Destination: {
          Mode: 'AWS/S3',
          BucketName: ENV['AWS_BUCKET'],
          ObjectKey: derivative,
          ContentType: 'REPLACE',
          Parameters: {
            ContentDisposition: "attachment; filename=\"#{File.basename(derivative)}\""
          }
        }
      }
    end
  end

  def publish_porter_sns(message)
    return false if Rails.env.test? || !SNS_CLIENT.present?

    SNS_CLIENT.publish({
                         topic_arn: ENV['PORTER_SNS_TOPIC_ARN'],
                         message: message.to_json
                       })
  end
end
