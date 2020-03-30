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

  def process!
    return if complete?

    with_lock do
      submit_porter_job to_global_id.to_s, asset_url do
        [
          {
            Type: 'Copy',
            Mode: 'AWS/S3',
            BucketName: ENV['AWS_BUCKET'],
            ObjectKey: "#{fixerable_final_path}/#{filename}",
            ContentType: 'REPLACE',
            Parameters: {
              ContentDisposition: "attachment; filename=\"#{filename}\""
            }
          },
          { Type: 'Inspect' },
        ] + thumbnail_tasks
      end
    end
  end

  def remove!; end

  private

  def thumbnail_tasks
    # Before we can ask carrierwave for the derivative filenames, we need to
    # tell it where we are going to put the original (this matters on create)
    current_filename = file.filename
    self.filename = filename if current_filename.nil?

    tasks = ImageUploader.version_formats.map do |(name, dimensions)|
      derivative = file.public_send(name).path
      {
        Type: 'Image',
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
          ObjectKey: derivative,
          ContentType: 'REPLACE',
          Parameters: {
            ContentDisposition: "attachment; filename=\"#{File.basename(derivative)}\""
          }
        }
      }
    end

    # Cleaning up after ourselves from before. This shouldn't matter, but in
    # the interest of correctness...
    self.filename = nil if current_filename.nil?

    tasks
  end

end
