class Image < PRXModel

  self.abstract_class = true

  mount_uploader :file, ImageUploader, mount_on: :filename

  def url(options={})
    v = options[:version]
    v = nil if (v.blank? || v.to_s == 'original')
    file.try(:url, *v)
  end

end
