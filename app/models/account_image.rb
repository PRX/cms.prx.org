# encoding: utf-8

class AccountImage < PRXModel
  
  belongs_to :account

  mount_uploader :file, ImageUploader, mount_on: :filename

  def url(options={})
    v = options[:version]
    v = nil if (v.blank? || v.to_s == 'original')
    file.try(:url, *v)
  end

end
