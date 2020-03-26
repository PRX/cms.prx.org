# encoding: utf-8

require 'aws-sdk'
require 'securerandom'

class Image < BaseModel

  self.abstract_class = true

  include PublicAsset
  include Fixerable
  include ValidityFlag
  include Portered

  CALLBACK_QUEUE = "#{ENV['RAILS_ENV']}_cms_image_callback".freeze

  porter_callbacks sqs: CALLBACK_QUEUE

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
    return if complete?

    Image.transaction do
      update_attribute :porter_job_id, SecureRandom.uuid
      submit_porter_job "#{porter_job_id}:copy", asset_url do
        {
          Type: 'Copy',
          Mode: 'AWS/S3',
          BucketName: ENV['AWS_BUCKET'],
          ObjectKey: "#{fixerable_final_path}/#{filename}"
        }
      end
    end
  end

  def analyze_file!
    return if complete?

    Image.transaction do
      update_attribute :porter_job_id, SecureRandom.uuid
      submit_porter_job "#{porter_job_id}:analyze", fixerable_final_storage_url, Type: 'Inspect'
    end
  end

  def generate_thumbnails!(format)
    return if complete?

    Image.transaction do
      update_attribute :porter_job_id, SecureRandom.uuid
      submit_porter_job "#{porter_job_id}:thumb", fixerable_final_storage_url do
        ImageUploader.version_formats.map do |(name, dimensions)|
          {
            Type: 'Image',
            Format: format,
            Metadata: 'PRESERVE',
            Resize: {
              Fit: 'contain',
              Height: dimensions[1],
              Position: 'centre',
              Width: dimensions[0]
            },
            Destination: {
              Mode: 'AWS/S3',
              BucketName: ENV['AWS_BUCKET'],
              ObjectKey: file.public_send(name).path
            }
          }
        end
      end
    end
  end

  def remove!; end
end
