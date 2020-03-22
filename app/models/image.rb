# encoding: utf-8

require 'aws-sdk'
require 'securerandom'

class Image < BaseModel
  SNS_CLIENT = Aws::SNS::Client.new

  self.abstract_class = true

  include PublicAsset
  include Fixerable
  include ValidityFlag

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
    status.nil? || status == COMPLETE
  end

  def self.policy_class
    ImagePolicy
  end

  def transform!
    if file.upload_path.present?
      self.porter_job_id = SecureRandom.uuid
      SNS_CLIENT.publish(
        topic_arn: ENV['PORTER_SNS_TOPIC_ARN'],
        message: {
          Job: {
            Id: porter_job_id,
            Source: {
              Mode: 'AWS/S3',
              BucketName: ENV['AWS_BUCKET'],
              ObjectKey: file.upload_path
            },
            Tasks: [
              { Type: 'Inspect' },
              {
                Type: 'Copy',
                Mode: 'AWS/S3',
                BucketName: ENV['AWS_BUCKET'],
                ObjectKey: file.path
              }
            ] + resize_tasks,
            Callbacks: [
              {
                Type: 'AWS/SQS',
                Queue: "https://sqs.#{ENV['AWS_REGION']}.amazonaws.com/#{ENV['AWS_ACCOUNT_ID']}/#{ENV['RAILS_ENV']}_cms_image_callback",
              }
            ]
          }
        }.to_json
      )
    else
      false
    end
  end

  def remove!
    true
  end

  private

  def resize_tasks
    ImageUploader.version_formats.map do |(name, dimensions)|
      {
        Type: 'Image',
        Format: 'png', # TODO: Make this conform to existing format
        Metadata: 'PRESERVE',
        Resize: {
          Fit: 'contain',
          Height: dimensions[1],
          Position: 'centre',
          Width: dimensions[0]
        },
        Destination: {
          Mode: 'AWS/S3',
          BucketName: 'prx-porter-sandbox',
          ObjectKey: file.send(name).path
        }
      }
    end
  end

end
