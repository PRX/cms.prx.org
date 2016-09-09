# encoding: utf-8

class Image < BaseModel

  self.abstract_class = true

  include PublicAsset
  include Fixerable

  UPLOADED = 'uploaded'.freeze
  NOTFOUND = 'not found'.freeze
  INVALID  = 'invalid'.freeze
  FAILED   = 'failed'.freeze
  COMPLETE = 'complete'.freeze

  alias_attribute :upload, :upload_path

  mount_uploader :file, ImageUploader, mount_on: :filename
  skip_callback :commit, :after, :remove_file! # don't remove s3 file
  fixerable_upload :upload, :file

  before_validation do
    if upload
      self.status ||= UPLOADED
    end
  end

  def self.policy_class
    ImagePolicy
  end

  # for backwards compatibility, null statuses are considered final
  def fixerable_final?
    status.nil? || status == COMPLETE
  end
end
