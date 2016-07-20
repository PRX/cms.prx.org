# encoding: utf-8

class Image < BaseModel

  self.abstract_class = true

  include PublicAsset

  mount_uploader :file, ImageUploader, mount_on: :filename
  alias_attribute :upload, :remote_file_url

  # not all the tables have these columns, story images do
  def caption
    self.try(:read_attribute, :caption)
  end

  def credit
    self.try(:read_attribute, :credit)
  end

  def self.policy_class
    ImagePolicy
  end
end
