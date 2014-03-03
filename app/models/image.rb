class Image < BaseModel

  self.abstract_class = true

  include PublicAsset

  mount_uploader :file, ImageUploader, mount_on: :filename

end
