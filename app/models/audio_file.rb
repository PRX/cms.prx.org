class AudioFile < PRXModel

  belongs_to :audio_version
  has_one :story, through: :audio_version

  acts_as_list scope: :audio_version
  acts_as_paranoid

end
