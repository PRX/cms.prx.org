# encoding: utf-8

class AudioFile < BaseModel

  include PublicAsset

  UPLOADED         = 'uploaded'
  VALIDATING       = 'validating'
  VALID            = 'valid'
  INVALID          = 'invalid'
  COMPLETE         = 'complete'
  TRANSFORMING     = 'creating mp3s'
  TRANSFORM_FAILED = 'creating mp3s failed'
  TRANSFORMED      = 'mp3s created'

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
