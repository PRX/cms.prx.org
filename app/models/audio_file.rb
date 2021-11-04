# encoding: utf-8

class AudioFile < BaseModel
  include PublicAsset
  include Fixerable
  include ValidityFlag
  include Portered

  CALLBACK_QUEUE = ENV['SQS_AUDIO_CALLBACK_QUEUE_NAME']

  porter_callbacks sqs: CALLBACK_QUEUE

  belongs_to :account
  belongs_to :audio_version

  has_one :story, through: :audio_version

  acts_as_paranoid

  alias_attribute :upload, :upload_path
  alias_attribute :duration, :length

  mount_uploader :file, AudioFileUploader, mount_on: :filename
  skip_callback :commit, :after, :remove_file! # don't remove s3 file
  fixerable_upload :upload, :file

  before_save :set_position, :set_status, only: [:update, :create]
  after_commit :update_version_status
  after_commit :touch_audio_version
  after_destroy :update_version_status

  MP3_CONTENT_TYPE = 'audio/mpeg'.freeze
  VIDEO_CONTENT_TYPE = 'video/mpeg'.freeze

  before_validation do
    if upload
      self.status ||= UPLOADED
    end

    if !account_id && story.try(:account_id)
      self.account = story.account
    end
  end

  def touch_audio_version
    audio_version.try(:touch)
  end

  def fixerable_final?
    [INVALID, VALID, COMPLETE, TRANSFORMING, TRANSFORM_FAILED, TRANSFORMED].include? status
  end

  def enclosure_url
    audio? ? public_url(version: :broadcast, extension: 'mp3') : public_url
  end

  def enclosure_content_type
    audio? ? MP3_CONTENT_TYPE : content_type
  end

  def audio?
    content_type.present? && content_type.starts_with?('audio/')
  end

  def video?
    content_type.present? && content_type.starts_with?('video/')
  end

  def compliant_with_template?
    status_message.nil?
  end

  def update_version_status
    return unless audio_version
    audio_version.with_lock do
      audio_version.save!
    end
  end

  def set_position
    if audio_version && position.to_i <= 0
      self.position = audio_version.audio_files.last.try(:position).to_i + 1
    end
  end

  def set_status
    # only do template validations once the audio callback worker has succeeded
    return if [UPLOADED, NOTFOUND, FAILED].include?(status)

    vtpl = audio_version.try(:audio_version_template)
    ftpl = vtpl.try(:audio_file_templates).try(:find) { |aft| aft.position == position }
    errors = vtpl.try(:validate_audio_file, self) || ftpl.try(:validate_audio_file, self)

    if errors.blank?
      self.status_message = nil
      self.status = COMPLETE
    else
      self.status = INVALID
      self.status_message = errors
    end
  end

  def process!
    return if status != UPLOADED

    broadcast_filename = "#{File.basename(filename, '.*')}_broadcast#{File.extname(filename).downcase}"
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
        {
          Type: 'Copy',
          Mode: 'AWS/S3',
          BucketName: ENV['AWS_BUCKET'],
          ObjectKey: "#{fixerable_final_path}/#{broadcast_filename}",
          ContentType: 'REPLACE',
          Parameters: {
            ContentDisposition: "attachment; filename=\"#{broadcast_filename}\""
          }
        },
        { Type: 'Inspect' }
      ]
    end
  end

end
