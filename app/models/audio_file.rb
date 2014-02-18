# encoding: utf-8

class AudioFile < PRXModel

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

  mount_uploader :file, AudioFileUploader, mount_on: :filename

  def asset_url(options={})
    v = options[:version]
    v = nil if (v.blank? || v.to_s == 'original')
    file.try(:url, *v)
  end

  def public_asset_filename
    File.basename(file.path)
  end

  def update_file!(name)
    filename_will_change!
    raw_write_attribute(:filename, name)
    save!
  end

end
