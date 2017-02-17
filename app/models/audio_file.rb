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

  before_save :validate_on_template, only: [:update, :create]

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
    audio_errors.nil?
  end

  def validate_on_template
    # don't bother checking template for audio file that's not yet ready
    # note: this does mean that files previously deemed invalid by template
    # will never make it past this line & will stay INVALID.
    return if [NOTFOUND, VALIDATING, INVALID, FAILED].include?(status)

    template = audio_version.
               try(:audio_version_template).
               try(:audio_file_templates).
               try(:find) { |aft| aft.position == position }
    return unless template

    errors = template.validate_audio_file(self)
    if errors.empty?
      self.audio_errors = nil
    else
      self.status = INVALID
      self.audio_errors = errors
    end
  end
end
