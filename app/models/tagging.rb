# encoding: utf-8

class Tagging < BaseModel
  belongs_to :user_tag, foreign_key: :tag_id
  belongs_to :taggable, polymorphic: true, touch: true

  validates_uniqueness_of :tag_id, scope: [:taggable_id, :taggable_type]
end
