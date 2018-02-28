# encoding: utf-8

class Tagging < BaseModel
  belongs_to :user_tag, foreign_key: :tag_id
  belongs_to :taggable, polymorphic: true, touch: true

  validates_uniqueness_of :tag_id, scope: %i[taggable_id taggable_type]

  def owner
    taggable
  end

  def self.policy_class
    OwnedPolicy
  end
end
