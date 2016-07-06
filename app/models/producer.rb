# encoding: utf-8

class Producer < BaseModel

  belongs_to :story, -> { with_deleted }, foreign_key: 'piece_id', touch: true
  belongs_to :user, -> { with_deleted }, touch: true

  acts_as_paranoid

  def full_name
    user.try(:name) || name
  end
end
