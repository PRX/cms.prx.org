class UserTag < BaseModel
  self.table_name = 'tags'

  has_many :taggings
  has_many :taggables, through: :taggings

  def to_tag
    name
  end
end
