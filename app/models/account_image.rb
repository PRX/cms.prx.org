# encoding: utf-8

class AccountImage < PRXModel
  
  belongs_to :account

  mount_uploader :file, ImageUploader, mount_on: :filename

  def owner
    account.becomes(Account)
  end

  def url(options={})
    v = options[:version]
    v = nil if (v.blank? || v.to_s == 'original')
    file.try(:url, *v)
  end

  # validates_presence_of :filename

  # #file system for now, will quickly move this to s3 after stable
  # has_attachment :storage => AppConfig.storage_backend,
  #                :processor => :MiniMagick,
  #                :content_type=>:image,
  #                :max_size => 10.megabytes,
  #                :path_prefix => 'public/account_images',
  #                :thumbnails => { :square => '75x75', :small=>'120x120', :medium=>'240x240' }

  # attr_accessible :thumbnail_resize_options, :content_type, :filename, :uploaded_data, :account, :account_id

end
