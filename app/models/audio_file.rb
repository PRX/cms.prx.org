# encoding: utf-8

class AudioFile < BaseModel

  include PublicAsset

  UPLOADED         = "uploaded"               # audio on s3 in upload, not in audio_file yet
  VALIDATING       = "validating"             # audio copied from upload, now checking file
  VALID            = "valid"                  # validation passed, need to create mp3s
  INVALID          = "invalid"                # validation failed (dead end)
  COMPLETE         = "complete"               # dropbox or basic upload worked, need to create mp3s
  TRANSFORMING     = "creating mp3s"          # was valid or complete, now making mp3s
  TRANSFORM_FAILED = "creating mp3s failed"   # mp3 creation failed (dead end)
  TRANSFORMED      = "mp3s created"           # mp3 creation worked, done! (dead end)

  belongs_to :account

  belongs_to :audio_version
  has_one :story, through: :audio_version

  acts_as_list scope: :audio_version
  acts_as_paranoid

  alias_attribute :upload, :upload_path
  alias_attribute :duration, :length

  mount_uploader :file, AudioFileUploader, mount_on: :filename

  before_validation do
    if upload
      self.status ||= UPLOADED
    end

    if !account && story
      self.account = story.account
    end
  end

  def asset_url(options={})
    v = options[:version]
    v = nil if (v.blank? || v.to_s == 'original')
    final_location? ? file.try(:url, *v) : upload
  end

  def public_asset_filename
    filename
  end

  def filename
    f = read_attribute(:filename) || URI.parse(upload || '').path
    File.basename(f) if f
  end

  def final_location?
    [VALID, COMPLETE, TRANSFORMING, TRANSFORM_FAILED, TRANSFORMED].include? status
  end

  def self.policy_class
    AccountablePolicy
  end
end
