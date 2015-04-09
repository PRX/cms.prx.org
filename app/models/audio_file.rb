# encoding: utf-8

class AudioFile < BaseModel

  include PublicAsset

  UPLOADED_TO_S3           = "uploaded"               # audio on s3 in upload, not in audio_file yet
  VALIDATION_IN_PROCESS    = "validating"             # audio copied from upload, now checking file
  VALID_AUDIO              = "valid"                  # validation passed, need to create mp3s
  INVALID_AUDIO            = "invalid"                # validation failed (dead end)
  REMOTE_UPLOAD_COMPLETED  = "complete"               # dropbox or basic upload worked, need to create mp3s
  TRANSFORM_IN_PROGRESS    = "creating mp3s"          # was valid or complete, now making mp3s
  TRANSFORM_FAILED         = "creating mp3s failed"   # mp3 creation failed (dead end)
  TRANSFORMED              = "mp3s created"           # mp3 creation worked, done! (dead end)

  belongs_to :audio_version
  has_one :story, through: :audio_version

  acts_as_list scope: :audio_version
  acts_as_paranoid

  alias_attribute :duration, :length

  mount_uploader :file, AudioFileUploader, mount_on: :filename

  after_commit :process_audio_file, on: :create

  def process_audio_file
    # start a copy & validate task

  end

  def self.policy_class
    StoryAttributePolicy
  end

  # TODO: overrides handle when file not yet copied, if we want to bother

  # # public asset overrides for uploaded but not copied audio
  # def public_asset_filename
  #   File.basename(file.path || upload_path)
  # end

  # def asset_url(options={})
  #   return super if file.path
  #   return nil if !upload_path
  # end

end


# two use cases

# 1) file has been uploaded to an s3 bucket via cloudfront
#   in the api, send the path for that file to the audio_file
#   on receiving this path, save it, and then copy to proper bucket and such
