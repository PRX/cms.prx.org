class Story < PRXModel

  self.table_name = 'pieces'

  has_many :audio_versions, -> { where(promos: false) }
  has_many :audio_files, through: :audio_versions

  acts_as_paranoid

  scope :published, lambda { where('published_at is not null') }

end
