class AudioVersion < PRXModel

  belongs_to :story, class_name: 'Story', foreign_key: 'piece_id', with_deleted: true 
  has_many :audio_files, -> { order :position }, dependent: :destroy
  
  acts_as_paranoid

end
