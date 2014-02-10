class Story < PRXModel

  self.table_name = 'pieces'

  acts_as_paranoid

  scope :published, lambda { where('published_at is not null') }

end
