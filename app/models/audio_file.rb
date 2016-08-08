# encoding: utf-8

class AudioFile < BaseModel

  include PublicAsset
  include Fixerable

  UPLOADED         = 'uploaded'.freeze
  NOTFOUND         = 'not found'.freeze
  VALIDATING       = 'validating'.freeze
  VALID            = 'valid'.freeze
  INVALID          = 'invalid'.freeze
  FAILED           = 'failed'.freeze
  COMPLETE         = 'complete'.freeze
  TRANSFORMING     = 'creating mp3s'.freeze
  TRANSFORM_FAILED = 'creating mp3s failed'.freeze
  TRANSFORMED      = 'mp3s created'.freeze

  SINGLE_CHANNEL = 'Single Channel'.freeze
  DUAL_CHANNEL   = 'Dual Channel'.freeze
  STEREO         = 'Stereo'.freeze
  JOINT_STEREO   = 'JStereo'.freeze

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
end
