class Story < PRXModel
  # db compatibility
  self.table_name = 'pieces'

  scope :published, lambda { where('published_at is not null') }
end
