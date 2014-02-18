# encoding: utf-8

class StoryImage < PRXModel

  self.table_name = 'piece_images'
  
  belongs_to :story, class_name: 'Story', foreign_key: 'piece_id', with_deleted: true 

  acts_as_list scope: :piece

  mount_uploader :file, ImageUploader, mount_on: :filename do
    def store_dir    
      "public/piece_images/#{model.id}"
    end
  end

  def owner
    story
  end

  def url(options={})
    v = options[:version]
    v = nil if (v.blank? || v.to_s == 'original')
    file.try(:url, *v)
  end

end
