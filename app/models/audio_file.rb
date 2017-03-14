# encoding: utf-8

class AudioFile < BaseModel
  include PublicAsset
  include Fixerable
  include ValidityFlag

  belongs_to :account
  belongs_to :audio_version, touch: true

  has_one :story, through: :audio_version

  acts_as_list scope: :audio_version
  acts_as_paranoid

  alias_attribute :upload, :upload_path
  alias_attribute :duration, :length

  mount_uploader :file, AudioFileUploader, mount_on: :filename
  skip_callback :commit, :after, :remove_file! # don't remove s3 file
  fixerable_upload :upload, :file

  before_save :set_status, only: [:update, :create]
  after_save :update_version_status, if: :status_changed?
  after_destroy :update_version_status

  before_validation do
    if upload
      self.status ||= UPLOADED
    end

    if !account && story
      self.account = story.account
    end
  end

  def fixerable_final?
    [VALID, COMPLETE, TRANSFORMING, TRANSFORM_FAILED, TRANSFORMED].include? status
  end

  def compliant_with_template?
    status_message.nil?
  end

  def update_version_status
    audio_version.try(:save!)
  end

  def set_status
    # only do template validations once the audio callback worker has succeeded
    if status == UPLOADED
      return
    elsif status == NOTFOUND
      self.status_message = "Audio file #{label} not found."
      return
    elsif status == FAILED
      self.status_message = "Audio file #{label} failed to process."
      return
    end

    template = audio_version.
               try(:audio_version_template).
               try(:audio_file_templates).
               try(:find) { |aft| aft.position == position }

    errors = template ? template.validate_audio_file(self) : []

    if errors.empty?
      self.status_message = nil
      self.status = COMPLETE
    else
      self.status = INVALID
      self.status_message = errors
    end
  end
end
